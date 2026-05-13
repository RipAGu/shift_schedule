import 'package:flutter/material.dart';

import '../features/calendar/ui/app_tab_bar.dart';
import '../features/calendar/ui/calendar_page.dart';
import '../features/pattern/ui/pattern_page.dart';
import '../features/shift_types/ui/shift_types_page.dart';
import '../features/stats/ui/stats_page.dart';
import 'tokens.dart';

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
    // Scaffold 가 body 의 MediaQuery.padding.bottom 에 탭바 높이 + 시스템 nav 인셋을
    // 자동 주입 → 페이지 SafeArea 가 알아서 컨텐츠를 끌어올림. extendBody:true 로
    // 탭바 블러 백드롭 뒤로 페이지 컨텐츠가 비치게 유지.
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: AppTab.values.indexOf(_active),
        children: const [
          CalendarPage(),
          PatternPage(),
          StatsPage(),
          ShiftTypesPage(),
        ],
      ),
      bottomNavigationBar: AppTabBar(active: _active, onTap: _setTab),
    );
  }
}
