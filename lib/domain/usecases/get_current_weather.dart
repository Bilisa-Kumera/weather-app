import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeather {
  GetCurrentWeather(this.repository);
  final WeatherRepository repository;

  Future<Weather> call(String query) => repository.getCurrentWeather(query);
}
