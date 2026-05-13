import 'package:flutter/material.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key, required this.stats, required this.customs});

  final Map<String, int> stats;
  final List<CustomShift> customs;

  @override
  Widget build(BuildContext context) {
    final workDays =
        (stats[Shift.day.key] ?? 0) + (stats[Shift.night.key] ?? 0);
    // 캘린더 하단 요약: 주/야/비 3개 고정 표시 (디자인 유지).
    const visible = <Shift>[Shift.day, Shift.night, Shift.off];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 78),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '이번 달 근무',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text4,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '총 '),
                      TextSpan(
                        text: '$workDays',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontFeatures: tabularNumbers,
                        ),
                      ),
                      const TextSpan(text: '일 근무해요'),
                    ],
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in visible) ...[
                _StatItem(shift: s, count: stats[s.key] ?? 0),
                if (s != visible.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.shift, required this.count});

  final Shift shift;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: shift.solid,
              letterSpacing: -0.4,
              height: 1,
              fontFeatures: tabularNumbers,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            shift.name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text4,
            ),
          ),
        ],
      ),
    );
  }
}
