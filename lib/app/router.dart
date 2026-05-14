import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/shift.dart';
import '../features/calendar/view_model/calendar_state.dart';
import '../features/calendar/view_model/calendar_view_model.dart';
import '../features/holidays/data/holiday_repository.dart';
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
      _syncWidget();
    });
  }

  // 위젯이 표시할 수 있는 모든 날짜의 공휴일 — 캘린더 페이지가 watch 하는
  // 3개년 (현재 ±1) 과 동일한 범위로 외부달 셀까지 커버.
  Set<String> _collectHolidays() {
    final year = DateTime
        .now()
        .year;
    final keys = <String>{};
    for (final y in [year - 1, year, year + 1]) {
      final map = ref
          .read(yearHolidaysProvider(y))
          .value;
      if (map != null) keys.addAll(map.keys);
    }
    return keys;
  }

  void _syncWidget() {
    final state = ref.read(calendarViewModelProvider);
    final customs = ref.read(shiftTypesViewModelProvider);
    widgetSyncService.sync(
      state,
      customs: customs,
      holidays: _collectHolidays(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(onboardingControllerProvider);

    ref.listen<CalendarState>(
      calendarViewModelProvider,
          (_, _) => _syncWidget(),
    );
    ref.listen<List<CustomShift>>(
      shiftTypesViewModelProvider,
          (_, _) => _syncWidget(),
    );
    // 공휴일 캐시가 fetch 완료되면 (특히 첫 실행 시 빈 캐시 → 네트워크 응답)
    // 위젯에 즉시 반영되도록 3개년 모두 listen.
    final year = DateTime
        .now()
        .year;
    for (final y in [year - 1, year, year + 1]) {
      ref.listen<AsyncValue<Map<String, String>>>(
        yearHolidaysProvider(y),
            (_, _) => _syncWidget(),
      );
    }

    // 루트에서 뒤로가기 = 앱 종료. 기본 Android 동작 (moveTaskToBack) 대신
    // SystemNavigator.pop() 으로 활동 finish → 앱 닫힘. 시트/다이얼로그가 떠
    // 있을 땐 Navigator 가 먼저 처리하므로 PopScope 까지 안 옴.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: completed ? const HomeShell() : const OnboardingScreen(),
    );
  }
}
