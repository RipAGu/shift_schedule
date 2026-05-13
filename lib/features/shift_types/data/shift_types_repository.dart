import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/shift.dart';
import 'shift_types_storage.dart';

part 'shift_types_repository.g.dart';

@Riverpod(keepAlive: true)
ShiftTypesStorage shiftTypesStorage(Ref ref) {
  throw UnimplementedError('overridden in main()');
}

@Riverpod(keepAlive: true)
ShiftTypesRepository shiftTypesRepository(Ref ref) {
  return ShiftTypesRepository(ref.watch(shiftTypesStorageProvider));
}

class ShiftTypesRepository {
  ShiftTypesRepository(this._storage);

  final ShiftTypesStorage _storage;

  List<CustomShift> getAll() => _storage.readAll();

  Future<void> putAll(List<CustomShift> customs) => _storage.writeAll(customs);

  String genId() => ShiftTypesStorage.genId();
}
