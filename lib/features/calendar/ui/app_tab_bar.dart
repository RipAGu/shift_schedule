import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/tokens.dart';

enum AppTab { calendar, pattern, stats, settings }

class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.active});

  final AppTab active;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(top: 6, bottom: 26),
          decoration: const BoxDecoration(
            color: Color(0xF5FFFFFF),
            border: Border(
              top: BorderSide(color: AppColors.lineSoft),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Item(icon: Icons.calendar_today_outlined, label: '캘린더', on: active == AppTab.calendar),
              _Item(icon: Icons.refresh, label: '패턴', on: active == AppTab.pattern),
              _Item(icon: Icons.bar_chart, label: '통계', on: active == AppTab.stats),
              _Item(icon: Icons.settings_outlined, label: '설정', on: active == AppTab.settings),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.on});
  final IconData icon;
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final color = on ? AppColors.blue : AppColors.text5;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 10.5,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
