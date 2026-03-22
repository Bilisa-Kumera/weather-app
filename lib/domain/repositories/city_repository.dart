import '../entities/city.dart';

abstract class CityRepository {
  Future<List<City>> searchCities(String query);
  Future<City?> getSavedCity();
  Future<void> saveCity(City city);
}
