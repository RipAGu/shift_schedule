// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_types_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShiftTypesViewModel)
final shiftTypesViewModelProvider = ShiftTypesViewModelProvider._();

final class ShiftTypesViewModelProvider
    extends $NotifierProvider<ShiftTypesViewModel, List<CustomShift>> {
  ShiftTypesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shiftTypesViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shiftTypesViewModelHash();

  @$internal
  @override
  ShiftTypesViewModel create() => ShiftTypesViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CustomShift> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CustomShift>>(value),
    );
  }
}

String _$shiftTypesViewModelHash() =>
    r'a64b01d61da4e37965f006695ad89fd078691a1b';

abstract class _$ShiftTypesViewModel extends $Notifier<List<CustomShift>> {
  List<CustomShift> build();

  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<CustomShift>, List<CustomShift>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CustomShift>, List<CustomShift>>,
              List<CustomShift>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
