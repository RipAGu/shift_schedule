import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'features/calendar/data/calendar_repository.dart';
import 'features/calendar/data/calendar_storage.dart';
import 'features/holidays/data/holiday_repository.dart';
import 'features/holidays/data/holiday_storage.dart';
import 'features/onboarding/data/onboarding_storage.dart';
import 'features/onboarding/view_model/onboarding_controller.dart';
import 'features/shift_types/data/legacy_migration.dart';
import 'features/shift_types/data/shift_types_repository.dart';
import 'features/shift_types/data/shift_types_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final calendarStorage = await CalendarStorage.open();
  final holidayStorage = await HolidayStorage.open();
  final onboardingStorage = await OnboardingStorage.open();
  final shiftTypesStorage = await ShiftTypesStorage.open();

  // 구버전 한글 enum.name 저장값 → 새 string-key 변환 (1회).
  await migrateLegacyShiftNames(
    cycleBox: calendarStorage.cycle,
    overridesBox: calendarStorage.overrides,
    shiftTypesStorage: shiftTypesStorage,
  );

  runApp(
    ProviderScope(
      overrides: [
        calendarStorageProvider.overrideWithValue(calendarStorage),
        holidayStorageProvider.overrideWithValue(holidayStorage),
        onboardingStorageProvider.overrideWithValue(onboardingStorage),
        shiftTypesStorageProvider.overrideWithValue(shiftTypesStorage),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '교대근무 캘린더',
      theme: lightTheme,
      routerConfig: router,
    );
  }
}
