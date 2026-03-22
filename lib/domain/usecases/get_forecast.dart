import '../entities/forecast.dart';
import '../repositories/weather_repository.dart';

class GetForecast {
  GetForecast(this.repository);
  final WeatherRepository repository;

  Future<Forecast> call(String query, {int days = 7}) =>
      repository.getForecast(query, days: days);
}
