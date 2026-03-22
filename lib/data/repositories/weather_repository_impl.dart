import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remote, this._local);

  final WeatherRemoteDataSource _remote;
  final WeatherLocalDataSource _local;

  @override
  Future<Weather> getCurrentWeather(String query) async {
    final cached = _local.getCachedCurrent(query);
    final timestamp = _local.getCurrentTimestamp(query);
    final isFresh = timestamp != null &&
        DateTime.now().difference(timestamp) <= AppConstants.currentWeatherTtl;

    if (cached != null && isFresh) {
      return cached.toEntity();
    }

    try {
      final remote = await _remote.getCurrentWeather(query);
      await _local.cacheCurrent(query, remote);
      return remote.toEntity();
    } on ServerException catch (e) {
      if (cached != null) {
        return cached.toEntity();
      }
      throw ServerFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (_) {
      throw UnknownFailure('Unexpected error');
    }
  }

  @override
  Future<Forecast> getForecast(String query, {int days = 7}) async {
    final cached = _local.getCachedForecast(query);
    final timestamp = _local.getForecastTimestamp(query);
    final isFresh = timestamp != null &&
        DateTime.now().difference(timestamp) <= AppConstants.forecastTtl;

    if (cached != null && isFresh) {
      return cached.toEntity();
    }

    try {
      final remote = await _remote.getForecast(query, days: days);
      await _local.cacheForecast(query, remote);
      return remote.toEntity();
    } on ServerException catch (e) {
      if (cached != null) {
        return cached.toEntity();
      }
      throw ServerFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (_) {
      throw UnknownFailure('Unexpected error');
    }
  }

  @override
  Future<List<DailyForecast>> getHistory(String query, {int days = 7}) async {
    try {
      final cached = _local.getHistory(query, days: days);

      try {
        final remote = await _remote.getHistory(query, days: days);
        if (remote.isNotEmpty) {
          await _local.cacheHistory(query, remote);
          return remote.map((e) => e.toEntity()).toList();
        }
      } catch (_) {
        // Fall back to cached history when remote history is unavailable.
      }

      return cached.map((e) => e.toEntity()).toList();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (_) {
      return [];
    }
  }
}
