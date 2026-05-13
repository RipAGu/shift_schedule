import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/tokens.dart';

enum AppTab { calendar, pattern, stats, settings }

class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.active, this.onTap});

  final AppTab active;
  final ValueChanged<AppTab>? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
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
              children: [
                Expanded(child: _Item(icon: Icons.calendar_today_outlined,
                    label: '캘린더',
                    tab: AppTab.calendar,
                    active: active,
                    onTap: onTap)),
                Expanded(child: _Item(icon: Icons.refresh,
                    label: '패턴',
                    tab: AppTab.pattern,
                    active: active,
                    onTap: onTap)),
                Expanded(child: _Item(icon: Icons.bar_chart,
                    label: '통계',
                    tab: AppTab.stats,
                    active: active,
                    onTap: onTap)),
                Expanded(child: _Item(icon: Icons.tune,
                    label: '근무종류',
                    tab: AppTab.settings,
                    active: active,
                    onTap: onTap)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AppTab tab;
  final AppTab active;
  final ValueChanged<AppTab>? onTap;

  @override
  Widget build(BuildContext context) {
    final on = active == tab;
    final color = on ? AppColors.blue : AppColors.text5;
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(tab),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
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
        ),
      ),
    );
  }
}
