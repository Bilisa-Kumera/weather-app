import 'package:equatable/equatable.dart';

class HourlyForecast extends Equatable {
  const HourlyForecast({
    required this.time,
    required this.tempC,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.isDay,
  });

  final DateTime time;
  final double tempC;
  final String conditionText;
  final String conditionIconUrl;
  final bool isDay;

  @override
  List<Object?> get props => [time, tempC, conditionText, conditionIconUrl, isDay];
}

class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.avgHumidity,
    required this.maxWindKph,
  });

  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final String conditionText;
  final String conditionIconUrl;
  final int avgHumidity;
  final double maxWindKph;

  @override
  List<Object?> get props => [
        date,
        maxTempC,
        minTempC,
        conditionText,
        conditionIconUrl,
        avgHumidity,
        maxWindKph,
      ];
}

class Forecast extends Equatable {
  const Forecast({
    required this.daily,
    required this.hourly,
  });

  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  @override
  List<Object?> get props => [daily, hourly];
}
