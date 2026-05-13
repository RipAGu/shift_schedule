import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/date_key.dart';
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

  List<String> getCycle() => _storage.readCycle();
  DateTime getAnchorDate() => _storage.readAnchorDate();
  Map<DateKey, Note> getAllNotes() => _storage.readAllNotes();

  Map<DateKey, String> getAllOverrides() => _storage.readAllOverrides();

  Future<void> putNote(DateKey key, Note note) =>
      _storage.notes.put(key, note);
  Future<void> deleteNote(DateKey key) => _storage.notes.delete(key);

  Future<void> putOverride(DateKey key, String shiftKey) =>
      _storage.writeOverride(key, shiftKey);

  Future<void> deleteOverride(DateKey key) => _storage.deleteOverride(key);

  Future<void> putCycle(List<String> cycle) => _storage.writeCycle(cycle);

  Future<void> putAnchorDate(DateTime date) => _storage.writeAnchorDate(date);
}
