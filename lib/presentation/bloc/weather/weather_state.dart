part of 'weather_bloc.dart';

enum WeatherStatus { initial, loading, success, failure, refreshing, empty }

class WeatherState extends Equatable {
  const WeatherState({
    required this.status,
    required this.weather,
    required this.forecast,
    required this.history,
    required this.selectedDate,
    this.message,
  });

  final WeatherStatus status;
  final Weather? weather;
  final Forecast? forecast;
  final List<DailyForecast> history;
  final DateTime selectedDate;
  final String? message;

  factory WeatherState.initial() => WeatherState(
        status: WeatherStatus.initial,
        weather: null,
        forecast: null,
        history: const [],
        selectedDate: DateTime.now(),
      );

  WeatherState copyWith({
    WeatherStatus? status,
    Weather? weather,
    Forecast? forecast,
    List<DailyForecast>? history,
    DateTime? selectedDate,
    String? message,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      history: history ?? this.history,
      selectedDate: selectedDate ?? this.selectedDate,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, weather, forecast, history, selectedDate, message];
}
