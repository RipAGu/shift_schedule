import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/date_key.dart';
import '../domain/note.dart';

part 'calendar_state.freezed.dart';

@freezed
abstract class CalendarState with _$CalendarState {
  const factory CalendarState({
    required DateTime focusedMonth,
    DateTime? selectedDay,
    required List<String> cycle,
    required DateTime anchorDate,
    required Map<DateKey, Note> notes,
    required Map<DateKey, String> overrides,
  }) = _CalendarState;
}
