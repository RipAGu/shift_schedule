import 'dart:convert';
import 'dart:math';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../core/shift.dart';

class ShiftTypesStorage {
  ShiftTypesStorage({required this.box});

  final Box<dynamic> box;
  static const _kCustomsKey = 'customs';

  static Future<ShiftTypesStorage> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>('shift_types');
    return ShiftTypesStorage(box: box);
  }

  List<CustomShift> readAll() {
    final raw = box.get(_kCustomsKey);
    if (raw is! List) return const [];
    final result = <CustomShift>[];
    for (final e in raw) {
      try {
        if (e is String) {
          final j = jsonDecode(e) as Map<String, dynamic>;
          result.add(CustomShift.fromJson(j));
        } else if (e is Map) {
          result.add(CustomShift.fromJson(Map<String, dynamic>.from(e)));
        }
      } catch (_) {
        // skip malformed
      }
    }
    return result;
  }

  Future<void> writeAll(List<CustomShift> customs) async {
    await box.put(
      _kCustomsKey,
      customs.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  // 'c_xxxxxxxx' 형태 — base 근무(id='day' 등)와 구분되도록 prefix 부여.
  static String genId() {
    final r = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return 'c_${List.generate(8, (_) => chars[r.nextInt(chars.length)]).join()}';
  }
}
