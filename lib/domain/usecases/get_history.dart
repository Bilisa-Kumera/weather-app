import '../entities/forecast.dart';
import '../repositories/weather_repository.dart';

class GetHistory {
  GetHistory(this.repository);
  final WeatherRepository repository;

  Future<List<DailyForecast>> call(String query, {int days = 7}) =>
      repository.getHistory(query, days: days);
}
