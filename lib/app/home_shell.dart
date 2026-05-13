import 'package:flutter/material.dart';

import '../features/calendar/ui/app_tab_bar.dart';
import '../features/calendar/ui/calendar_page.dart';
import '../features/pattern/ui/pattern_page.dart';
import '../features/shift_types/ui/shift_types_page.dart';
import '../features/stats/ui/stats_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  AppTab _active = AppTab.calendar;

  void _setTab(AppTab tab) {
    if (tab == _active) return;
    setState(() => _active = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IndexedStack(
          index: AppTab.values.indexOf(_active),
          children: const [
            CalendarPage(),
            PatternPage(),
            StatsPage(),
            ShiftTypesPage(),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AppTabBar(active: _active, onTap: _setTab),
        ),
      ],
    );
  }
}
