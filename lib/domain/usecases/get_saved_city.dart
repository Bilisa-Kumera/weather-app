import '../entities/city.dart';
import '../repositories/city_repository.dart';

class GetSavedCity {
  GetSavedCity(this.repository);
  final CityRepository repository;

  Future<City?> call() => repository.getSavedCity();
}
