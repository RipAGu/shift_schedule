import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/date_key.dart';
import '../../../core/shift.dart';
import '../domain/note.dart';
import 'calendar_storage.dart';

part 'calendar_repository.g.dart';

@Riverpod(keepAlive: true)
CalendarStorage calendarStorage(Ref ref) {
  throw UnimplementedError('overridden in main()');
}

@Riverpod(keepAlive: true)
CalendarRepository calendarRepository(Ref ref) {
  return CalendarRepository(ref.watch(calendarStorageProvider));
}

class CalendarRepository {
  CalendarRepository(this._storage);

  final CalendarStorage _storage;

  List<ShiftKind> getCycle() => _storage.readCycle();
  DateTime getAnchorDate() => _storage.readAnchorDate();
  Map<DateKey, Note> getAllNotes() => _storage.readAllNotes();
  Map<DateKey, ShiftKind> getAllOverrides() => _storage.readAllOverrides();

  Future<void> putNote(DateKey key, Note note) =>
      _storage.notes.put(key, note);
  Future<void> deleteNote(DateKey key) => _storage.notes.delete(key);
  Future<void> putOverride(DateKey key, ShiftKind shift) =>
      _storage.overrides.put(key, shift.name);
  Future<void> deleteOverride(DateKey key) => _storage.overrides.delete(key);
}
