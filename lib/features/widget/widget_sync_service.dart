import 'dart:convert';
import 'dart:developer' as dev;

import 'package:home_widget/home_widget.dart';

import '../../core/date_key.dart';
import '../../core/shift.dart';
import '../calendar/view_model/calendar_state.dart';

const String kHomeWidgetAppGroup = 'group.com.ripagu.shiftapp';
const String kHomeWidgetiOSName = 'ShiftCalendarWidget';
const String _kPayloadKey = 'payload';

class WidgetSyncService {
  WidgetSyncService();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await HomeWidget.setAppGroupId(kHomeWidgetAppGroup);
    _initialized = true;
  }

  Future<void> sync(
    CalendarState state, {
    required List<CustomShift> customs,
  }) async {
    try {
      await _ensureInitialized();

      // Swift 위젯이 색상 hex 와 표시 정보를 모두 알 수 있도록 함께 전송.
      // 알려진 base 키는 Swift 의 기본 매핑을 사용하지만, 커스텀 근무도
      // 같은 형식의 사전을 통해 폴백 가능.
      // 저장소의 모든 근무(=기본 5종 시드 + 사용자 추가)를 전송.
      // 비어있다면 정적 fallback 5종을 보내 위젯이 아예 빈 상태가 되는 걸 막음.
      final shifts = <String, Map<String, dynamic>>{};
      if (customs.isEmpty) {
        for (final s in Shift.baseShifts) {
          shifts[s.key] = _shiftJson(s);
        }
      } else {
        for (final c in customs) {
          shifts[c.key] = _shiftJson(c.toShift());
        }
      }

      final payload = <String, dynamic>{
        'anchorDate': toDateKey(state.anchorDate),
        'cycle': state.cycle,
        'overrides': state.overrides,
        'shifts': shifts,
      };

      final json = jsonEncode(payload);
      await HomeWidget.saveWidgetData(_kPayloadKey, json);
      await HomeWidget.updateWidget(iOSName: kHomeWidgetiOSName);

      dev.log(
        'Synced widget — cycle:${state.cycle.length}, '
        'overrides:${state.overrides.length}, '
        'shifts:${shifts.length}',
        name: 'widget',
      );
    } catch (e) {
      dev.log('Widget sync failed: $e', name: 'widget');
    }
  }
}

WidgetSyncService get widgetSyncService => _instance;
final WidgetSyncService _instance = WidgetSyncService();

Map<String, dynamic> _shiftJson(Shift s) => {
  'key': s.key,
  'short': s.short,
  'name': s.name,
  'solid': _hex(s.solid.toARGB32()),
  'soft': _hex(s.soft.toARGB32()),
};

String _hex(int argb) {
  // 0xAARRGGBB -> "#RRGGBB"
  final rgb = argb & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
