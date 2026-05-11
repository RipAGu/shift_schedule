import 'package:flutter/material.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key, required this.stats});

  final Map<ShiftKind, int> stats;

  @override
  Widget build(BuildContext context) {
    final workDays = (stats[ShiftKind.day] ?? 0) + (stats[ShiftKind.night] ?? 0);
    const visible = [ShiftKind.day, ShiftKind.night, ShiftKind.off];

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
              for (final k in visible) ...[
                _StatItem(kind: k, count: stats[k] ?? 0),
                if (k != visible.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.kind, required this.count});

  final ShiftKind kind;
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
              color: kind.solid,
              letterSpacing: -0.4,
              height: 1,
              fontFeatures: tabularNumbers,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            kind.name,
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
