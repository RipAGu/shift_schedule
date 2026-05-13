import 'package:flutter/material.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key, required this.stats, required this.customs});

  final Map<String, int> stats;
  final List<CustomShift> customs;

  @override
  Widget build(BuildContext context) {
    // 근무하는 날 = isOff 가 아닌 모든 근무의 합.
    var workDays = 0;
    for (final c in customs) {
      if (!c.isOff) workDays += stats[c.id] ?? 0;
    }
    // 우측 요약: '주간', '야간', '비번' 키에 해당하는 근무를 우선 노출.
    // 사용자가 base 를 삭제했다면 customs 첫 3개로 폴백.
    final preferredKeys = ['day', 'night', 'off'];
    final visible = <Shift>[];
    for (final key in preferredKeys) {
      final s = shiftByKey(key, customs);
      if (s != null) visible.add(s);
    }
    if (visible.length < 3) {
      for (final c in customs) {
        if (visible.length >= 3) break;
        final s = c.toShift();
        if (!visible.any((v) => v.key == s.key)) visible.add(s);
      }
    }

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
              for (var i = 0; i < visible.length; i++) ...[
                _StatItem(shift: visible[i], count: stats[visible[i].key] ?? 0),
                if (i != visible.length - 1) const SizedBox(width: 10),
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
