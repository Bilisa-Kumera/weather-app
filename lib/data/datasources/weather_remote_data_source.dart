import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/env.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

class WeatherRemoteDataSource {
  WeatherRemoteDataSource(this._client);

  final ApiClient _client;

  Future<WeatherModel> getCurrentWeather(String query) async {
    _ensureKey();
    _log('GET /current.json q=$query');
    try {
      final response = await _client.dio.get(
        '/current.json',
        queryParameters: {'q': query},
      );
      _log('Response ${response.statusCode} /current.json');
      _ensureOk(response);
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Unexpected response format');
      }
      return WeatherModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      final msg = _message(e);
      _log('DioException /current.json: $msg');
      throw ServerException(msg);
    }
  }

  Future<ForecastModel> getForecast(String query, {int days = 7}) async {
    _ensureKey();
    _log('GET /forecast.json q=$query days=$days');
    try {
      final response = await _client.dio.get(
        '/forecast.json',
        queryParameters: {'q': query, 'days': days, 'aqi': 'no', 'alerts': 'no'},
      );
      _log('Response ${response.statusCode} /forecast.json');
      _ensureOk(response);
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Unexpected response format');
      }
      return ForecastModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      final msg = _message(e);
      _log('DioException /forecast.json: $msg');
      throw ServerException(msg);
    }
  }

  Future<List<DailyForecastModel>> getHistory(String query, {int days = 7}) async {
    _ensureKey();
    final now = DateTime.now();
    final list = <DailyForecastModel>[];

    for (int i = days; i >= 1; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dt = _yyyyMmDd(date);
      _log('GET /history.json q=$query dt=$dt');

      try {
        final response = await _client.dio.get(
          '/history.json',
          queryParameters: {'q': query, 'dt': dt},
        );
        _log('Response ${response.statusCode} /history.json dt=$dt');
        _ensureOk(response);

        final data = response.data;
        if (data is! Map) {
          continue;
        }

        final model = ForecastModel.fromJson(Map<String, dynamic>.from(data));
        if (model.daily.isNotEmpty) {
          list.add(model.daily.first);
        }
      } on DioException catch (e) {
        final msg = _message(e);
        _log('DioException /history.json dt=$dt: $msg');
      }
    }

    return list;
  }

  void _ensureOk(Response response) {
    final status = response.statusCode ?? 0;
    if (status >= 400) {
      throw ServerException('Server error ($status)');
    }
  }

  void _ensureKey() {
    if (Env.weatherApiKey.isEmpty || Env.weatherApiKey == 'YOUR_API_KEY_HERE') {
      throw ServerException('Missing Weather API key');
    }
    _log('Weather API key loaded: ${_maskKey(Env.weatherApiKey)}');
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final root = Map<String, dynamic>.from(data);
      final error = root['error'];
      final msg = error is Map ? error['message'] as String? : null;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    if (e.response?.statusCode != null) {
      return 'Server error (${e.response?.statusCode})';
    }
    return e.message ?? 'Server error';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[WeatherAPI] $message');
    }
  }

  String _maskKey(String key) {
    if (key.length <= 6) return '***';
    return '${key.substring(0, 3)}***${key.substring(key.length - 3)}';
  }

  String _yyyyMmDd(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
