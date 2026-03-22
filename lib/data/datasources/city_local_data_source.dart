import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/city_model.dart';

class CityLocalDataSource {
  CityLocalDataSource(this._settingsBox);

  final Box _settingsBox;

  Future<void> saveCity(CityModel city) async {
    try {
      await _settingsBox.put(AppConstants.keySelectedCity, city.toJson());
      await _settingsBox.put(AppConstants.keyOnboardingComplete, true);
    } catch (e) {
      throw CacheException('Failed to save city');
    }
  }

  CityModel? getSavedCity() {
    final raw = _settingsBox.get(AppConstants.keySelectedCity);
    if (raw is Map) {
      return CityModel.fromLocalJson(raw.cast<String, dynamic>());
    }
    return null;
  }

  bool isOnboardingComplete() {
    final value = _settingsBox.get(AppConstants.keyOnboardingComplete);
    return value == true;
  }

  Future<void> setOnboardingComplete(bool value) async {
    try {
      await _settingsBox.put(AppConstants.keyOnboardingComplete, value);
    } catch (e) {
      throw CacheException('Failed to save onboarding status');
    }
  }
}
