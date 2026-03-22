import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/city_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._local);
  final CityLocalDataSource _local;

  @override
  Future<bool> isComplete() async {
    try {
      return _local.isOnboardingComplete();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> complete() async {
    try {
      await _local.setOnboardingComplete(true);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
