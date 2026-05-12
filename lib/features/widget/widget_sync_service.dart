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

  Future<void> sync(CalendarState state) async {
    try {
      await _ensureInitialized();

      final payload = <String, dynamic>{
        'anchorDate': toDateKey(state.anchorDate),
        'cycle': state.cycle.map(_shiftKey).toList(),
        'overrides': state.overrides
            .map((key, value) => MapEntry(key, _shiftKey(value))),
      };

      final json = jsonEncode(payload);
      await HomeWidget.saveWidgetData(_kPayloadKey, json);
      await HomeWidget.updateWidget(iOSName: kHomeWidgetiOSName);

      dev.log(
        'Synced widget — cycle:${state.cycle.length}, '
        'overrides:${state.overrides.length}',
        name: 'widget',
      );
    } catch (e) {
      // Widget sync은 보조 기능이라 실패해도 앱 동작에 영향 없게
      dev.log('Widget sync failed: $e', name: 'widget');
    }
  }
}

WidgetSyncService get widgetSyncService => _instance;
final WidgetSyncService _instance = WidgetSyncService();

/// `ShiftKind.day` → `'day'` (Dart enum identifier, not the Korean display name).
/// Custom `.name` 필드 때문에 `s.name` 이 '주간' 을 반환하므로 toString 으로 우회.
String _shiftKey(ShiftKind k) => k.toString().substring('ShiftKind.'.length);
