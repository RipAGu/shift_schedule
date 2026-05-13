import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/shift.dart';
import '../features/calendar/view_model/calendar_state.dart';
import '../features/calendar/view_model/calendar_view_model.dart';
import '../features/onboarding/ui/onboarding_screen.dart';
import '../features/onboarding/view_model/onboarding_controller.dart';
import '../features/shift_types/view_model/shift_types_view_model.dart';
import '../features/widget/widget_sync_service.dart';
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

class _RootGate extends ConsumerStatefulWidget {
  const _RootGate();

  @override
  ConsumerState<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<_RootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(calendarViewModelProvider);
      final customs = ref.read(shiftTypesViewModelProvider);
      widgetSyncService.sync(state, customs: customs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(onboardingControllerProvider);

    ref.listen<CalendarState>(
      calendarViewModelProvider,
          (prev, next) {
        final customs = ref.read(shiftTypesViewModelProvider);
        widgetSyncService.sync(next, customs: customs);
      },
    );
    ref.listen<List<CustomShift>>(
      shiftTypesViewModelProvider,
          (prev, next) {
        final state = ref.read(calendarViewModelProvider);
        widgetSyncService.sync(state, customs: next);
      },
    );

    return completed ? const HomeShell() : const OnboardingScreen();
  }
}
