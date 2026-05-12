import 'package:flutter/material.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';

class CalendarCell extends StatelessWidget {
  const CalendarCell({
    super.key,
    required this.day,
    required this.shift,
    this.isToday = false,
    this.isSelected = false,
    this.isOutside = false,
    this.emoji,
    this.memo,
    this.holiday,
    this.overridden = false,
  });

  final DateTime day;
  final ShiftKind shift;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;
  final String? emoji;
  final String? memo;
  final String? holiday;
  final bool overridden;

  @override
  Widget build(BuildContext context) {
    final dim = isOutside ? 0.35 : 1.0;
    final hasHoliday = holiday != null && !isOutside;
    final dayColor = isToday
        ? Colors.white
        : hasHoliday
            ? AppColors.red
            : day.weekday == DateTime.sunday
                ? AppColors.red
                : day.weekday == DateTime.saturday
                    ? AppColors.blue
                    : AppColors.text1;

    final dayText = Text(
      '${day.day}',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        fontWeight: (isToday || hasHoliday)
            ? FontWeight.w800
            : FontWeight.w600,
        letterSpacing: -0.3,
        color: dayColor,
        fontFeatures: tabularNumbers,
      ),
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.blue : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 4),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 22,
                child: Center(
                  child: isToday
                      ? Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: dayText,
                        )
                      : Opacity(opacity: dim, child: dayText),
                ),
              ),
              const SizedBox(height: 3),
              if (!isOutside)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: shift.soft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    shift.short,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: shift.solid,
                      height: 1.4,
                    ),
                  ),
                ),
              if (!isOutside) ...[
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  height: 12,
                  child: hasHoliday
                      ? Text(
                          holiday!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.red,
                            height: 1.1,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: (memo != null && memo!.isNotEmpty)
                      ? Text(
                          memo!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: AppColors.text3,
                            height: 1.2,
                          ),
                        )
                      : null,
                ),
              ],
            ],
          ),
          if (emoji != null)
            Positioned(
              top: 2,
              right: -2,
              child: Text(emoji!, style: const TextStyle(fontSize: 10, height: 1)),
            ),
          if (overridden)
            Positioned(
              top: 3,
              left: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.text1,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
