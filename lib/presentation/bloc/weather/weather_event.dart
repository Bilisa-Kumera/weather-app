part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeather extends WeatherEvent {
  const LoadWeather(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class RefreshWeather extends WeatherEvent {
  const RefreshWeather(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class SelectDate extends WeatherEvent {
  const SelectDate(this.date);
  final DateTime date;

  @override
  List<Object?> get props => [date];
}
