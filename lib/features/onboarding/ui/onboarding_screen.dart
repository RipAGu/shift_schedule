import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';
import '../view_model/onboarding_controller.dart';

const _defaultCycle = <Shift>[
  Shift.day,
  Shift.day,
  Shift.night,
  Shift.night,
  Shift.off,
  Shift.off,
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _WelcomeStep(),
                  _ShiftInfoStep(),
                  _PatternPreviewStep(cycle: _defaultCycle),
                ],
              ),
            ),
            _BottomBar(
              page: _page,
              onNext: _next,
              onFinish: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.page,
    required this.onNext,
    required this.onFinish,
  });

  final int page;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    const labels = ['시작하기', '다음', '캘린더 시작하기'];
    final isLast = page == 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DotsIndicator(current: page, total: 3),
          const SizedBox(height: 18),
          _PrimaryButton(
            label: labels[page],
            onTap: isLast ? onFinish : onNext,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Step 1 — Welcome
// =====================================================================
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Text(
            '교대근무 캘린더',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.blue,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '근무표,\n한 번 설정으로\n끝내요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
              letterSpacing: -0.8,
              height: 1.25,
            ),
          ),
          SizedBox(height: 32),
          Expanded(
            child: Center(child: _HeroIllustration()),
          ),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    final layout = [
      'D', 'D', 'N', 'N', 'O',
      'O', 'D', 'D', 'N', 'N',
      'O', 'O', 'D', 'D', 'N',
      'N', 'O', 'O', 'D', 'D',
    ];
    return SizedBox(
      width: 240,
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Calendar card
          Positioned(
            left: 18,
            top: 24,
            width: 180,
            height: 180,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.18),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: GridView.count(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final code in layout)
                    Container(
                      decoration: BoxDecoration(
                        color: _colorFor(code).withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Floating chip top-right
          Positioned(
            right: -4,
            top: 6,
            child: Transform.rotate(
              angle: 6 * 3.1415926 / 180,
              child: _FloatingChip(emoji: '🎉', label: '내일 비번!'),
            ),
          ),
          // Floating chip bottom-left
          Positioned(
            left: -4,
            bottom: 0,
            child: Transform.rotate(
              angle: -5 * 3.1415926 / 180,
              child: _FloatingChip(emoji: '💪', label: '야간 D-2'),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(String code) {
    switch (code) {
      case 'D':
        return Shift.day.solid;
      case 'N':
        return Shift.night.solid;
      case 'O':
        return Shift.off.solid;
      default:
        return AppColors.text5;
    }
  }
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Step 2 — Shift selection
// =====================================================================
class _ShiftInfoStep extends StatelessWidget {
  const _ShiftInfoStep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 1 / 2',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '근무 종류는\n자유롭게 바꿔써요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
              letterSpacing: -0.6,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '기본 5종으로 시작하고, 이름·색상·시간을 바꾸거나\n새 근무를 언제든 추가할 수 있어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.text4,
              letterSpacing: -0.2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: Shift.baseShifts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) =>
                  _ShiftInfoCard(shift: Shift.baseShifts[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftInfoCard extends StatelessWidget {
  const _ShiftInfoCard({required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: shift.solid,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              shift.short,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shift.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  shift.time,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Step 3 — Pattern preview
// =====================================================================
class _PatternPreviewStep extends StatelessWidget {
  const _PatternPreviewStep({required this.cycle});

  final List<Shift> cycle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 2 / 2',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '반복할 순서를\n정해요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
              letterSpacing: -0.6,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '예시 패턴이에요. 다음 화면에서 바꿀 수 있어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.text4,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: cycle.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CycleRow(index: i, shift: cycle[i]),
            ),
          ),
          const SizedBox(height: 14),
          _CycleSummaryChip(length: cycle.length),
        ],
      ),
    );
  }
}

class _CycleRow extends StatelessWidget {
  const _CycleRow({required this.index, required this.shift});
  final int index;
  final Shift shift;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            '${index + 1}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.text5,
              fontFeatures: tabularNumbers,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: shift.soft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: shift.solid.withValues(alpha: 0.13),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: shift.solid,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shift.short,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  shift.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CycleSummaryChip extends StatelessWidget {
  const _CycleSummaryChip({required this.length});
  final int length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$length',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFeatures: tabularNumbers,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.text1,
                letterSpacing: -0.2,
              ),
              children: [
                TextSpan(
                  text: '$length',
                  style: const TextStyle(fontFeatures: tabularNumbers),
                ),
                const TextSpan(text: '일마다 반복돼요'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Shared
// =====================================================================
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == current ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == current
                  ? AppColors.blue
                  : i < current
                      ? AppColors.blueSoft2
                      : AppColors.line,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
