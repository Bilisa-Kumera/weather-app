import '../../domain/entities/forecast.dart';

class HourlyForecastModel {
  HourlyForecastModel({
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

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    final condition = _asMap(json['condition']);
    return HourlyForecastModel(
      time: DateTime.parse(json['time'] as String),
      tempC: (json['temp_c'] as num).toDouble(),
      conditionText: condition['text'] as String? ?? '',
      conditionIconUrl: _normalizeIcon(condition['icon'] as String?),
      isDay: (json['is_day'] as num?) == 1,
    );
  }

  HourlyForecast toEntity() => HourlyForecast(
        time: time,
        tempC: tempC,
        conditionText: conditionText,
        conditionIconUrl: conditionIconUrl,
        isDay: isDay,
      );

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temp_c': tempC,
        'condition_text': conditionText,
        'condition_icon': conditionIconUrl,
        'is_day': isDay,
      };
}

class DailyForecastModel {
  DailyForecastModel({
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

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    final day = _asMap(json['day']);
    final condition = _asMap(day['condition']);
    return DailyForecastModel(
      date: DateTime.parse(json['date'] as String),
      maxTempC: (day['maxtemp_c'] as num).toDouble(),
      minTempC: (day['mintemp_c'] as num).toDouble(),
      conditionText: condition['text'] as String? ?? '',
      conditionIconUrl: _normalizeIcon(condition['icon'] as String?),
      avgHumidity: (day['avghumidity'] as num?)?.toInt() ?? 0,
      maxWindKph: (day['maxwind_kph'] as num?)?.toDouble() ?? 0,
    );
  }

  DailyForecast toEntity() => DailyForecast(
        date: date,
        maxTempC: maxTempC,
        minTempC: minTempC,
        conditionText: conditionText,
        conditionIconUrl: conditionIconUrl,
        avgHumidity: avgHumidity,
        maxWindKph: maxWindKph,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'max_temp_c': maxTempC,
        'min_temp_c': minTempC,
        'condition_text': conditionText,
        'condition_icon': conditionIconUrl,
        'avg_humidity': avgHumidity,
        'max_wind_kph': maxWindKph,
      };
}

class ForecastModel {
  ForecastModel({
    required this.daily,
    required this.hourly,
  });

  final List<DailyForecastModel> daily;
  final List<HourlyForecastModel> hourly;

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final forecast = _asMap(json['forecast']);
    final forecastDays = _asListOfMap(forecast['forecastday']);

    final daily = forecastDays.map(DailyForecastModel.fromJson).toList(growable: false);
    final hourly = <HourlyForecastModel>[];
    for (final day in forecastDays) {
      final hours = _asListOfMap(day['hour']);
      hourly.addAll(hours.map(HourlyForecastModel.fromJson));
    }

    return ForecastModel(daily: daily, hourly: hourly);
  }

  Map<String, dynamic> toJson() => {
        'daily': daily.map((e) => e.toJson()).toList(),
        'hourly': hourly.map((e) => e.toJson()).toList(),
      };

  Forecast toEntity() => Forecast(
        daily: daily.map((e) => e.toEntity()).toList(),
        hourly: hourly.map((e) => e.toEntity()).toList(),
      );
}

String _normalizeIcon(String? icon) {
  if (icon == null || icon.isEmpty) return '';
  if (icon.startsWith('http')) return icon;
  return 'https:$icon';
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _asListOfMap(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}
