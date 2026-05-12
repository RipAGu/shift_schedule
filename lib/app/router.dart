import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/onboarding/ui/onboarding_screen.dart';
import '../features/onboarding/view_model/onboarding_controller.dart';
import 'home_shell.dart';

part 'router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _RootGate(),
      ),
    ],
  );
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(onboardingControllerProvider);
    return completed ? const HomeShell() : const OnboardingScreen();
  }
}
