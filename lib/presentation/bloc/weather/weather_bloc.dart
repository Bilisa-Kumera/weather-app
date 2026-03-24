import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/env.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/rain_notification_service.dart';
import '../../../domain/entities/forecast.dart';
import '../../../domain/entities/weather.dart';
import '../../../domain/usecases/get_current_weather.dart';
import '../../../domain/usecases/get_forecast.dart';
import '../../../domain/usecases/get_history.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc({
    required GetCurrentWeather getCurrentWeather,
    required GetForecast getForecast,
    required GetHistory getHistory,
    required RainNotificationService rainNotificationService,
  }) : _getCurrentWeather = getCurrentWeather,
       _getForecast = getForecast,
       _getHistory = getHistory,
       _rainNotificationService = rainNotificationService,
       super(WeatherState.initial()) {
    on<LoadWeather>(_onLoadWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<SelectDate>(_onSelectDate);
  }

  final GetCurrentWeather _getCurrentWeather;
  final GetForecast _getForecast;
  final GetHistory _getHistory;
  final RainNotificationService _rainNotificationService;

  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final current = await _getCurrentWeather(event.query);
      Forecast forecast = const Forecast(daily: [], hourly: []);
      List<DailyForecast> history = const [];

      try {
        forecast = await _getForecast(event.query, days: 8);
        history = await _getHistory(event.query, days: 7);
      } on Failure catch (e) {
        _log('Forecast/history failed: ${e.message}');
      } catch (e) {
        _log('Forecast/history failed: $e');
      }

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          weather: current,
          forecast: forecast,
          history: history,
          selectedDate: DateTime.now(),
          message: forecast.daily.isEmpty ? 'Tilmaamni hin argamne' : null,
        ),
      );
      await _syncRainAlert(current, forecast, event.query);
    } on Failure catch (e) {
      emit(state.copyWith(status: WeatherStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: WeatherStatus.failure,
          message: 'Daataan haala qilleensaa fe\'uu hin dandeenye',
        ),
      );
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(status: WeatherStatus.refreshing));
    try {
      final current = await _getCurrentWeather(event.query);
      Forecast forecast = const Forecast(daily: [], hourly: []);
      List<DailyForecast> history = const [];

      try {
        forecast = await _getForecast(event.query, days: 8);
        history = await _getHistory(event.query, days: 7);
      } on Failure catch (e) {
        _log('Forecast/history refresh failed: ${e.message}');
      } catch (e) {
        _log('Forecast/history refresh failed: $e');
      }

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          weather: current,
          forecast: forecast,
          history: history,
          message: forecast.daily.isEmpty ? 'Tilmaamni hin argamne' : null,
        ),
      );
      await _syncRainAlert(current, forecast, event.query);
    } on Failure catch (e) {
      emit(state.copyWith(status: WeatherStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: WeatherStatus.failure,
          message: 'Daataan haala qilleensaa haaromsuu hin dandeenye',
        ),
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<WeatherState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  Future<void> _syncRainAlert(
    Weather current,
    Forecast forecast,
    String query,
  ) async {
    try {
      await _rainNotificationService.syncRainAlert(
        cityName: current.city,
        query: query,
        weatherApiKey: Env.weatherApiKey,
        hourlyForecast: forecast.hourly,
        source: 'ui_refresh',
      );
    } catch (e) {
      _log('Rain notification sync failed: $e');
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[WeatherBloc] $message');
    }
  }
}
