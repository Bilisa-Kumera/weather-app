import '../entities/city.dart';
import '../repositories/city_repository.dart';

class SearchCities {
  SearchCities(this.repository);
  final CityRepository repository;

  Future<List<City>> call(String query) => repository.searchCities(query);
}
