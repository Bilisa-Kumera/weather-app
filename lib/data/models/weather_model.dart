import '../../domain/entities/weather.dart';

class WeatherModel {
  WeatherModel({
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

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = _asMap(json['location']);
    final current = _asMap(json['current']);
    final condition = _asMap(current['condition']);

    return WeatherModel(
      city: location['name'] as String? ?? '',
      country: location['country'] as String? ?? '',
      tempC: (current['temp_c'] as num).toDouble(),
      conditionText: condition['text'] as String? ?? '',
      conditionIconUrl: _normalizeIcon(condition['icon'] as String?),
      humidity: (current['humidity'] as num?)?.toInt() ?? 0,
      windKph: (current['wind_kph'] as num?)?.toDouble() ?? 0,
      feelsLikeC: (current['feelslike_c'] as num?)?.toDouble() ?? 0,
      isDay: (current['is_day'] as num?) == 1,
      lastUpdated: DateTime.parse(current['last_updated'] as String),
      uv: (current['uv'] as num?)?.toDouble() ?? 0,
      pressureMb: (current['pressure_mb'] as num?)?.toDouble() ?? 0,
    );
  }

  Weather toEntity() => Weather(
        city: city,
        country: country,
        tempC: tempC,
        conditionText: conditionText,
        conditionIconUrl: conditionIconUrl,
        humidity: humidity,
        windKph: windKph,
        feelsLikeC: feelsLikeC,
        isDay: isDay,
        lastUpdated: lastUpdated,
        uv: uv,
        pressureMb: pressureMb,
      );

  Map<String, dynamic> toJson() => {
        'city': city,
        'country': country,
        'temp_c': tempC,
        'condition_text': conditionText,
        'condition_icon': conditionIconUrl,
        'humidity': humidity,
        'wind_kph': windKph,
        'feelslike_c': feelsLikeC,
        'is_day': isDay,
        'last_updated': lastUpdated.toIso8601String(),
        'uv': uv,
        'pressure_mb': pressureMb,
      };

  factory WeatherModel.fromCache(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0,
      conditionText: json['condition_text'] as String? ?? '',
      conditionIconUrl: json['condition_icon'] as String? ?? '',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windKph: (json['wind_kph'] as num?)?.toDouble() ?? 0,
      feelsLikeC: (json['feelslike_c'] as num?)?.toDouble() ?? 0,
      isDay: json['is_day'] as bool? ?? true,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      uv: (json['uv'] as num?)?.toDouble() ?? 0,
      pressureMb: (json['pressure_mb'] as num?)?.toDouble() ?? 0,
    );
  }
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
