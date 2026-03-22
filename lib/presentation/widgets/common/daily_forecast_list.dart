import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../../domain/entities/forecast.dart';
import 'glass_card.dart';
import 'weather_icon.dart';

class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.forecast,
    required this.onTap,
  });

  final Forecast forecast;
  final ValueChanged<DailyForecast> onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return SizedBox(
      height: r.h(150),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.daily.length,
        separatorBuilder: (_, __) => SizedBox(width: r.w(12)),
        itemBuilder: (context, index) {
          final day = forecast.daily[index];
          return GestureDetector(
            onTap: () => onTap(day),
            child: GlassCard(
              borderRadius: r.r(20),
              padding: EdgeInsets.all(r.w(14)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayLabel(day.date),
                    style: TextStyle(
                      fontSize: r.sp(12),
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: r.h(8)),
                  WeatherIcon(url: day.conditionIconUrl, size: r.w(40)),
                  SizedBox(height: r.h(8)),
                  Text(
                    '${day.maxTempC.toStringAsFixed(0)}\u00B0C / ${day.minTempC.toStringAsFixed(0)}\u00B0C',
                    style: TextStyle(
                      fontSize: r.sp(12),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  String _dayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}

