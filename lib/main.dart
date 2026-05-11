import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'features/calendar/data/calendar_repository.dart';
import 'features/calendar/data/calendar_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await CalendarStorage.open();

  runApp(
    ProviderScope(
      overrides: [
        calendarStorageProvider.overrideWithValue(storage),
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
