import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'features/calendar/data/calendar_repository.dart';
import 'features/calendar/data/calendar_storage.dart';
import 'features/holidays/data/holiday_repository.dart';
import 'features/holidays/data/holiday_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final calendarStorage = await CalendarStorage.open();
  final holidayStorage = await HolidayStorage.open();

  runApp(
    ProviderScope(
      overrides: [
        calendarStorageProvider.overrideWithValue(calendarStorage),
        holidayStorageProvider.overrideWithValue(holidayStorage),
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
