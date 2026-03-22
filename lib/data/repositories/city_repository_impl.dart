import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/city_repository.dart';
import '../datasources/city_local_data_source.dart';
import '../datasources/city_remote_data_source.dart';
import '../models/city_model.dart';

class CityRepositoryImpl implements CityRepository {
  CityRepositoryImpl(this._remote, this._local);

  final CityRemoteDataSource _remote;
  final CityLocalDataSource _local;

  @override
  Future<List<City>> searchCities(String query) async {
    try {
      final results = await _remote.searchCities(query);
      return results.map((e) => e.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw UnknownFailure('City search failed');
    }
  }

  @override
  Future<City?> getSavedCity() async {
    try {
      final model = _local.getSavedCity();
      return model?.toEntity();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> saveCity(City city) async {
    try {
      await _local.saveCity(
        CityModel(name: city.name, country: city.country, lat: city.lat, lon: city.lon),
      );
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
