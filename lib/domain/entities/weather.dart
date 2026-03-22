import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  const Weather({
    required this.city,
    required this.country,
    required this.tempC,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.humidity,
    required this.windKph,
    required this.feelsLikeC,
    required this.isDay,
    required this.lastUpdated,
    required this.uv,
    required this.pressureMb,
  });

  final String city;
  final String country;
  final double tempC;
  final String conditionText;
  final String conditionIconUrl;
  final int humidity;
  final double windKph;
  final double feelsLikeC;
  final bool isDay;
  final DateTime lastUpdated;
  final double uv;
  final double pressureMb;

  @override
  List<Object?> get props => [
        city,
        country,
        tempC,
        conditionText,
        conditionIconUrl,
        humidity,
        windKph,
        feelsLikeC,
        isDay,
        lastUpdated,
        uv,
        pressureMb,
      ];
}
