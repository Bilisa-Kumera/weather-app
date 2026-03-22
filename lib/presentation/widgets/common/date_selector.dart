import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    final dates = List.generate(15, (index) => start.add(Duration(days: index)));

    return SizedBox(
      height: r.h(80),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => SizedBox(width: r.w(10)),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, selectedDate);
          return GestureDetector(
            onTap: () => onSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: r.w(14), vertical: r.h(12)),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.14)
                    : Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(r.r(16)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.34),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayLabel(date),
                    style: TextStyle(
                      fontSize: isSelected ? r.sp(14) : r.sp(11),
                      color: isSelected ?  Colors.white : Colors.white70,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: r.h(4)),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: isSelected ? r.sp(20) : r.sp(16),
                      color: isSelected ?  Colors.white : Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}
