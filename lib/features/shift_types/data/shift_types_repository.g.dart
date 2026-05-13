// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_types_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shiftTypesStorage)
final shiftTypesStorageProvider = ShiftTypesStorageProvider._();

final class ShiftTypesStorageProvider
    extends
        $FunctionalProvider<
          ShiftTypesStorage,
          ShiftTypesStorage,
          ShiftTypesStorage
        >
    with $Provider<ShiftTypesStorage> {
  ShiftTypesStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shiftTypesStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shiftTypesStorageHash();

  @$internal
  @override
  $ProviderElement<ShiftTypesStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShiftTypesStorage create(Ref ref) {
    return shiftTypesStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShiftTypesStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShiftTypesStorage>(value),
    );
  }
}

String _$shiftTypesStorageHash() => r'41d47b0943c319eff9f4de007e7d52773b2ec11b';

@ProviderFor(shiftTypesRepository)
final shiftTypesRepositoryProvider = ShiftTypesRepositoryProvider._();

final class ShiftTypesRepositoryProvider
    extends
        $FunctionalProvider<
          ShiftTypesRepository,
          ShiftTypesRepository,
          ShiftTypesRepository
        >
    with $Provider<ShiftTypesRepository> {
  ShiftTypesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shiftTypesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shiftTypesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShiftTypesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShiftTypesRepository create(Ref ref) {
    return shiftTypesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShiftTypesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShiftTypesRepository>(value),
    );
  }
}

String _$shiftTypesRepositoryHash() =>
    r'85233b3b52ac467520426ed95aab94c3125a387f';
