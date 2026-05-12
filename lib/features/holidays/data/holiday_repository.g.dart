// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(holidayService)
final holidayServiceProvider = HolidayServiceProvider._();

final class HolidayServiceProvider
    extends $FunctionalProvider<HolidayService, HolidayService, HolidayService>
    with $Provider<HolidayService> {
  HolidayServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holidayServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holidayServiceHash();

  @$internal
  @override
  $ProviderElement<HolidayService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HolidayService create(Ref ref) {
    return holidayService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HolidayService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HolidayService>(value),
    );
  }
}

String _$holidayServiceHash() => r'ea231757539fb4e8f7233dc91f8a0d15463d0d38';

@ProviderFor(holidayStorage)
final holidayStorageProvider = HolidayStorageProvider._();

final class HolidayStorageProvider
    extends $FunctionalProvider<HolidayStorage, HolidayStorage, HolidayStorage>
    with $Provider<HolidayStorage> {
  HolidayStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holidayStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holidayStorageHash();

  @$internal
  @override
  $ProviderElement<HolidayStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HolidayStorage create(Ref ref) {
    return holidayStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HolidayStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HolidayStorage>(value),
    );
  }
}

String _$holidayStorageHash() => r'e88eee1ae2ad7d78887162e74e34ae7b1a74ae6b';

@ProviderFor(holidayRepository)
final holidayRepositoryProvider = HolidayRepositoryProvider._();

final class HolidayRepositoryProvider
    extends
        $FunctionalProvider<
          HolidayRepository,
          HolidayRepository,
          HolidayRepository
        >
    with $Provider<HolidayRepository> {
  HolidayRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holidayRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holidayRepositoryHash();

  @$internal
  @override
  $ProviderElement<HolidayRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HolidayRepository create(Ref ref) {
    return holidayRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HolidayRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HolidayRepository>(value),
    );
  }
}

String _$holidayRepositoryHash() => r'e523eef0b3f493dd738323628004030a6a11b977';

@ProviderFor(yearHolidays)
final yearHolidaysProvider = YearHolidaysFamily._();

final class YearHolidaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          FutureOr<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $FutureProvider<Map<String, String>> {
  YearHolidaysProvider._({
    required YearHolidaysFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearHolidaysProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearHolidaysHash();

  @override
  String toString() {
    return r'yearHolidaysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>> create(Ref ref) {
    final argument = this.argument as int;
    return yearHolidays(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearHolidaysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearHolidaysHash() => r'70e50852912b4edc9cc7d545cc79cd891e48b6bd';

final class YearHolidaysFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, String>>, int> {
  YearHolidaysFamily._()
    : super(
        retry: null,
        name: r'yearHolidaysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  YearHolidaysProvider call(int year) =>
      YearHolidaysProvider._(argument: year, from: this);

  @override
  String toString() => r'yearHolidaysProvider';
}
