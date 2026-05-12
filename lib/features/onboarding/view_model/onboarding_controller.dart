import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/onboarding_storage.dart';

part 'onboarding_controller.g.dart';

@Riverpod(keepAlive: true)
OnboardingStorage onboardingStorage(Ref ref) {
  throw UnimplementedError('overridden in main()');
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  bool build() {
    return ref.read(onboardingStorageProvider).isCompleted();
  }

  Future<void> complete() async {
    await ref.read(onboardingStorageProvider).setCompleted();
    state = true;
  }
}
