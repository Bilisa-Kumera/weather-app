import 'package:flutter/material.dart';

class AppConstants {
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String defaultCity = 'Addis Ababa';
  static const Locale defaultLocale = Locale('om');

  static const Duration currentWeatherTtl = Duration(minutes: 30);
  static const Duration forecastTtl = Duration(hours: 2);

  static const String prefsLocaleCode = 'prefs_locale_code';
  static const String prefsThemeMode = 'prefs_theme_mode';
  static const String prefsRainMonitorEnabled = 'prefs_rain_monitor_enabled';

  static const String boxSettings = 'settings_box';
  static const String boxCache = 'cache_box';

  static const String keySelectedCity = 'selected_city';
  static const String keyOnboardingComplete = 'onboarding_complete';
}
