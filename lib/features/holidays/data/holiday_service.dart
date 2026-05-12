import 'dart:developer' as dev;

import 'package:dio/dio.dart';

class HolidayService {
  HolidayService({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static const _apiKey = String.fromEnvironment('HOLIDAY_API_KEY');
  static const _logName = 'holidays';

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl:
            'https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => dev.log(obj.toString(), name: '$_logName/http'),
      ),
    );
    return dio;
  }

  /// 공공데이터포털의 dateName 이 일자 형태로 오는 경우 자연어로 매핑.
  static const _nameNormalization = <String, String>{
    '1월1일': '신정',
  };

  /// Returns `{ 'YYYY-MM-DD': '공휴일이름', ... }`.
  /// API 키가 없거나 호출 실패 시 빈 맵 반환.
  Future<Map<String, String>> fetchYear(int year) async {
    if (_apiKey.isEmpty) {
      dev.log('HOLIDAY_API_KEY not set — skipping fetch for $year',
          name: _logName);
      return const {};
    }

    dev.log('Fetching $year (key: ${_apiKey.substring(0, 6)}…)',
        name: _logName);

    final response = await _dio.get<Map<String, dynamic>>(
      '/getRestDeInfo',
      queryParameters: {
        'ServiceKey': _apiKey,
        'solYear': year,
        'numOfRows': 100,
        '_type': 'json',
      },
    );

    final data = response.data;
    if (data == null) {
      dev.log('Empty response for $year', name: _logName);
      return const {};
    }

    final result = _parse(data);
    dev.log('Fetched $year — ${result.length} holidays', name: _logName);
    if (result.isNotEmpty) {
      final preview = result.entries
          .take(3)
          .map((e) => '${e.key}=${e.value}')
          .join(', ');
      dev.log('  e.g. $preview${result.length > 3 ? ', ...' : ''}',
          name: _logName);
    }
    return result;
  }

  Map<String, String> _parse(Map<String, dynamic> data) {
    final response = data['response'];
    if (response is! Map) {
      dev.log('Unexpected response shape: $data', name: _logName);
      return const {};
    }

    final header = response['header'];
    if (header is Map) {
      final code = header['resultCode'];
      final msg = header['resultMsg'];
      if (code != '00') {
        dev.log('API error: code=$code msg=$msg', name: _logName);
        return const {};
      }
    }

    final body = response['body'];
    if (body is! Map) return const {};

    final items = body['items'];
    if (items == null || items == '') return const {};

    final rawItem = (items as Map)['item'];
    final list = rawItem is List ? rawItem : [rawItem];

    final out = <String, String>{};
    for (final entry in list) {
      if (entry is! Map) continue;
      if (entry['isHoliday'] != 'Y') continue;
      final locdate = entry['locdate'];
      final dateName = entry['dateName'];
      if (locdate == null || dateName is! String) continue;

      final n = locdate is int ? locdate : int.tryParse('$locdate');
      if (n == null) continue;
      final y = n ~/ 10000;
      final m = (n ~/ 100) % 100;
      final d = n % 100;
      final key =
          '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

      out[key] = _nameNormalization[dateName] ?? dateName;
    }
    return out;
  }
}
