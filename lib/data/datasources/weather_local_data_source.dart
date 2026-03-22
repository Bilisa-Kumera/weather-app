import 'package:hive_flutter/hive_flutter.dart';

import '../../core/error/exceptions.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

class WeatherLocalDataSource {
  WeatherLocalDataSource(this._cacheBox);

  final Box _cacheBox;

  WeatherModel? getCachedCurrent(String query) {
    final key = 'current_$query';
    final cached = _cacheBox.get(key);
    if (cached is Map) {
      return WeatherModel.fromCache(Map<String, dynamic>.from(cached));
    }
    return null;
  }

  ForecastModel? getCachedForecast(String query) {
    final key = 'forecast_$query';
    final cached = _cacheBox.get(key);
    if (cached is Map) {
      final data = Map<String, dynamic>.from(cached);
      final daily = (data['daily'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map((e) => DailyForecastModel(
                date: DateTime.parse(e['date'] as String),
                maxTempC: (e['max_temp_c'] as num).toDouble(),
                minTempC: (e['min_temp_c'] as num).toDouble(),
                conditionText: e['condition_text'] as String? ?? '',
                conditionIconUrl: e['condition_icon'] as String? ?? '',
                avgHumidity: (e['avg_humidity'] as num?)?.toInt() ?? 0,
                maxWindKph: (e['max_wind_kph'] as num?)?.toDouble() ?? 0,
              ))
          .toList(growable: false);

      final hourly = (data['hourly'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map((e) => HourlyForecastModel(
                time: DateTime.parse(e['time'] as String),
                tempC: (e['temp_c'] as num).toDouble(),
                conditionText: e['condition_text'] as String? ?? '',
                conditionIconUrl: e['condition_icon'] as String? ?? '',
                isDay: e['is_day'] as bool? ?? true,
              ))
          .toList(growable: false);

      return ForecastModel(daily: daily, hourly: hourly);
    }
    return null;
  }

  Future<void> cacheCurrent(String query, WeatherModel model) async {
    try {
      await _cacheBox.put('current_$query', model.toJson());
      await _cacheBox.put('current_${query}_ts', DateTime.now().toIso8601String());
    } catch (_) {
      throw CacheException('Failed to cache current weather');
    }
  }

  Future<void> cacheForecast(String query, ForecastModel model) async {
    try {
      await _cacheBox.put('forecast_$query', model.toJson());
      await _cacheBox.put('forecast_${query}_ts', DateTime.now().toIso8601String());

      final today = DateTime.now();
      for (final day in model.daily) {
        final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
        final todayDate = DateTime(today.year, today.month, today.day);
        if (!dayDate.isAfter(todayDate)) {
          final key = _historyKey(query, day.date);
          await _cacheBox.put(key, day.toJson());
        }
      }
    } catch (_) {
      throw CacheException('Failed to cache forecast');
    }
  }

  Future<void> cacheHistory(String query, List<DailyForecastModel> days) async {
    try {
      for (final day in days) {
        await _cacheBox.put(_historyKey(query, day.date), day.toJson());
      }
    } catch (_) {
      throw CacheException('Failed to cache history');
    }
  }

  DateTime? getCurrentTimestamp(String query) {
    final raw = _cacheBox.get('current_${query}_ts');
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  DateTime? getForecastTimestamp(String query) {
    final raw = _cacheBox.get('forecast_${query}_ts');
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  List<DailyForecastModel> getHistory(String query, {int days = 7}) {
    final now = DateTime.now();
    final list = <DailyForecastModel>[];
    for (int i = days; i >= 1; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final raw = _cacheBox.get(_historyKey(query, date));
      if (raw is Map) {
        final data = Map<String, dynamic>.from(raw);
        list.add(
          DailyForecastModel(
            date: DateTime.parse(data['date'] as String),
            maxTempC: (data['max_temp_c'] as num).toDouble(),
            minTempC: (data['min_temp_c'] as num).toDouble(),
            conditionText: data['condition_text'] as String? ?? '',
            conditionIconUrl: data['condition_icon'] as String? ?? '',
            avgHumidity: (data['avg_humidity'] as num?)?.toInt() ?? 0,
            maxWindKph: (data['max_wind_kph'] as num?)?.toDouble() ?? 0,
          ),
        );
      }
    }
    return list;
  }

  String _historyKey(String query, DateTime date) {
    final keyDate = DateTime(date.year, date.month, date.day).toIso8601String();
    return 'history_${query}_$keyDate';
  }
}
