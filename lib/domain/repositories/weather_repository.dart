import '../entities/forecast.dart';
import '../entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getCurrentWeather(String query);
  Future<Forecast> getForecast(String query, {int days = 7});
  Future<List<DailyForecast>> getHistory(String query, {int days = 7});
}
