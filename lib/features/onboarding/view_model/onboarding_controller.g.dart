// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingStorage)
final onboardingStorageProvider = OnboardingStorageProvider._();

final class OnboardingStorageProvider
    extends
        $FunctionalProvider<
          OnboardingStorage,
          OnboardingStorage,
          OnboardingStorage
        >
    with $Provider<OnboardingStorage> {
  OnboardingStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStorageHash();

  @$internal
  @override
  $ProviderElement<OnboardingStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingStorage create(Ref ref) {
    return onboardingStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingStorage>(value),
    );
  }
}

String _$onboardingStorageHash() => r'881ff751fb3b4c5877b57272468185201c663f2a';

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

final class OnboardingControllerProvider
    extends $NotifierProvider<OnboardingController, bool> {
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingControllerHash() =>
    r'a116c0ddfd4a8b22a732d031ea5762665d51a63b';

abstract class _$OnboardingController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
