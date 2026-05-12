import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';
import '../../calendar/domain/shift_calculator.dart';
import '../../calendar/view_model/calendar_view_model.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final focused = state.focusedMonth;
    final stats = monthStats(
      year: focused.year,
      month: focused.month,
      cycle: state.cycle,
      anchorDate: state.anchorDate,
      overrides: state.overrides,
    );

    final lastDay = DateTime(focused.year, focused.month + 1, 0).day;
    final workDays =
        (stats[ShiftKind.day] ?? 0) + (stats[ShiftKind.night] ?? 0);
    final offDays = (stats[ShiftKind.off] ?? 0) +
        (stats[ShiftKind.holiday] ?? 0) +
        (stats[ShiftKind.vacation] ?? 0) +
        (stats[ShiftKind.compOff] ?? 0);
    final totalHours =
        ((stats[ShiftKind.day] ?? 0) + (stats[ShiftKind.night] ?? 0)) * 12;

    final trend = <_TrendItem>[];
    for (var i = -5; i <= 0; i++) {
      final d = DateTime(focused.year, focused.month + i, 1);
      final ms = monthStats(
        year: d.year,
        month: d.month,
        cycle: state.cycle,
        anchorDate: state.anchorDate,
        overrides: state.overrides,
      );
      final dCount = ms[ShiftKind.day] ?? 0;
      final nCount = ms[ShiftKind.night] ?? 0;
      trend.add(_TrendItem(
        label: '${d.month}월',
        day: dCount,
        night: nCount,
        total: dCount + nCount,
        isCurrent: i == 0,
      ));
    }
    final trendMax = trend.map((t) => t.total).fold<int>(1, (a, b) => a > b ? a : b);
    final trendAvg =
        (trend.map((t) => t.total).fold<int>(0, (a, b) => a + b) / trend.length).round();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(month: focused),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroCard(
                      stats: stats,
                      workDays: workDays,
                      totalDays: lastDay,
                    ),
                    const SizedBox(height: 10),
                    _MetricsRow(
                      stats: stats,
                      totalHours: totalHours,
                      offDays: offDays,
                    ),
                    const SizedBox(height: 10),
                    _TrendCard(
                      trend: trend,
                      trendMax: trendMax,
                      average: trendAvg,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendItem {
  const _TrendItem({
    required this.label,
    required this.day,
    required this.night,
    required this.total,
    required this.isCurrent,
  });
  final String label;
  final int day;
  final int night;
  final int total;
  final bool isCurrent;
}

class _Header extends StatelessWidget {
  const _Header({required this.month});
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '통계',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${month.year}년 ${month.month}월',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text4,
              fontFeatures: tabularNumbers,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.stats,
    required this.workDays,
    required this.totalDays,
  });

  final Map<ShiftKind, int> stats;
  final int workDays;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '이번 달 근무',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text4,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontFamily: 'Pretendard', height: 1),
              children: [
                TextSpan(
                  text: '$workDays',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1,
                    letterSpacing: -1,
                    fontFeatures: tabularNumbers,
                  ),
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  text: '일 / ',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                  ),
                ),
                TextSpan(
                  text: '$totalDays',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                    fontFeatures: tabularNumbers,
                  ),
                ),
                const TextSpan(
                  text: '일',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _StackedBar(stats: stats, totalDays: totalDays),
          const SizedBox(height: 14),
          _LegendGrid(stats: stats),
        ],
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.stats, required this.totalDays});
  final Map<ShiftKind, int> stats;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        color: AppColors.bg,
        child: Row(
          children: [
            for (final k in ShiftKind.values)
              if ((stats[k] ?? 0) > 0)
                Expanded(
                  flex: stats[k]!,
                  child: Container(color: k.solid),
                ),
            // remaining unaccounted space (shouldn't happen, but safe)
            if (_remaining(stats, totalDays) > 0)
              Expanded(flex: _remaining(stats, totalDays), child: const SizedBox()),
          ],
        ),
      ),
    );
  }

  int _remaining(Map<ShiftKind, int> s, int total) {
    final used = s.values.fold<int>(0, (a, b) => a + b);
    return (total - used).clamp(0, total);
  }
}

class _LegendGrid extends StatelessWidget {
  const _LegendGrid({required this.stats});
  final Map<ShiftKind, int> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final k in ShiftKind.values)
          _LegendItem(kind: k, count: stats[k] ?? 0),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.kind, required this.count});
  final ShiftKind kind;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: kind.solid,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$count',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1,
                        letterSpacing: -0.3,
                        height: 1,
                        fontFeatures: tabularNumbers,
                      ),
                    ),
                    const TextSpan(
                      text: ' 일',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text4,
                      ),
                    ),
                  ],
                  style: const TextStyle(fontFamily: 'Pretendard'),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                kind.name,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.stats,
    required this.totalHours,
    required this.offDays,
  });

  final Map<ShiftKind, int> stats;
  final int totalHours;
  final int offDays;

  @override
  Widget build(BuildContext context) {
    final dHours = (stats[ShiftKind.day] ?? 0) * 12;
    final nHours = (stats[ShiftKind.night] ?? 0) * 12;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MetricCard(
              label: '총 근무 시간',
              value: '$totalHours',
              unit: '시간',
              sublabel: '주간 ${dHours}h · 야간 ${nHours}h',
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              label: '쉬는 날',
              value: '$offDays',
              unit: '일',
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    this.sublabel,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final String? sublabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text4,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.6,
                    height: 1,
                    fontFeatures: tabularNumbers,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text4,
                  ),
                ),
              ],
              style: const TextStyle(fontFamily: 'Pretendard'),
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 6),
            Text(
              sublabel!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.text5,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.trend,
    required this.trendMax,
    required this.average,
  });

  final List<_TrendItem> trend;
  final int trendMax;
  final int average;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '최근 6개월 추이',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text4,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '평균 '),
                TextSpan(
                  text: '$average',
                  style: const TextStyle(fontFeatures: tabularNumbers),
                ),
                const TextSpan(text: '일/월'),
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
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < trend.length; i++) ...[
                  Expanded(child: _TrendBar(item: trend[i], trendMax: trendMax)),
                  if (i != trend.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({required this.item, required this.trendMax});
  final _TrendItem item;
  final int trendMax;

  @override
  Widget build(BuildContext context) {
    final opacity = item.isCurrent ? 1.0 : 0.6;
    final dRatio = item.day / trendMax;
    final nRatio = item.night / trendMax;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${item.total}',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: item.isCurrent ? AppColors.blue : AppColors.text5,
            fontFeatures: tabularNumbers,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 100 * nRatio,
                color: ShiftKind.night.solid.withValues(alpha: opacity),
              ),
              Container(
                height: 100 * dRatio,
                color: ShiftKind.day.solid.withValues(alpha: opacity),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: item.isCurrent ? FontWeight.w800 : FontWeight.w600,
            color: item.isCurrent ? AppColors.text1 : AppColors.text4,
          ),
        ),
      ],
    );
  }
}
