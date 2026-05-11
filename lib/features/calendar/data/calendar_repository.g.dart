// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(calendarStorage)
final calendarStorageProvider = CalendarStorageProvider._();

final class CalendarStorageProvider
    extends
        $FunctionalProvider<CalendarStorage, CalendarStorage, CalendarStorage>
    with $Provider<CalendarStorage> {
  CalendarStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarStorageHash();

  @$internal
  @override
  $ProviderElement<CalendarStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CalendarStorage create(Ref ref) {
    return calendarStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarStorage>(value),
    );
  }
}

String _$calendarStorageHash() => r'3d4eedc379a548fb9d5a2bfdc0324aa8619cdd5b';

@ProviderFor(calendarRepository)
final calendarRepositoryProvider = CalendarRepositoryProvider._();

final class CalendarRepositoryProvider
    extends
        $FunctionalProvider<
          CalendarRepository,
          CalendarRepository,
          CalendarRepository
        >
    with $Provider<CalendarRepository> {
  CalendarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarRepositoryHash();

  @$internal
  @override
  $ProviderElement<CalendarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalendarRepository create(Ref ref) {
    return calendarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarRepository>(value),
    );
  }
}

String _$calendarRepositoryHash() =>
    r'67fb8e18a70eaa2e97253b63fedc8a57beddd0aa';
