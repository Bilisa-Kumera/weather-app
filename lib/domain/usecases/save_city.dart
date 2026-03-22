import '../entities/city.dart';
import '../repositories/city_repository.dart';

class SaveCity {
  SaveCity(this.repository);
  final CityRepository repository;

  Future<void> call(City city) => repository.saveCity(city);
}
