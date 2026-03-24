import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/forecast.dart';
import '../constants/app_constants.dart';

class RainNotificationService {
  RainNotificationService(this._prefs);

  static const String rainAlertChannelKey = 'rain_alerts';
  static const String monitorChannelKey = 'rain_monitor_service';
  static const int rainAlertNotificationId = 5001;
  static const int monitorServiceNotificationId = 5002;

  static const String rainEventIsoKey = 'rain_event_time_iso';
  static const String rainEventCityKey = 'rain_event_city';
  static const String rainQueryKey = 'rain_alert_query';
  static const String rainCityKey = 'rain_alert_city';
  static const String weatherApiKeyPrefsKey = 'weather_api_key';

  final SharedPreferences _prefs;

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: rainAlertChannelKey,
        channelName: 'Rain Alerts',
        channelDescription: 'Notifies you when rain is expected soon',
        importance: NotificationImportance.High,
        defaultRingtoneType: DefaultRingtoneType.Notification,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: monitorChannelKey,
        channelName: 'Rain Monitor Service',
        channelDescription: 'Keeps rain monitoring active in the background',
        importance: NotificationImportance.Low,
        channelShowBadge: false,
        playSound: false,
        enableVibration: false,
      ),
    ], debug: false);
  }

  Future<void> cacheContext({
    required String query,
    required String cityName,
    required String weatherApiKey,
  }) async {
    await _prefs.setString(rainQueryKey, query);
    await _prefs.setString(rainCityKey, cityName);
    await _prefs.setString(weatherApiKeyPrefsKey, weatherApiKey);
  }

  Future<void> syncRainAlert({
    required String cityName,
    required String query,
    required String weatherApiKey,
    required List<HourlyForecast> hourlyForecast,
    Duration lookAhead = const Duration(minutes: 20),
    String source = 'app',
  }) async {
    await cacheContext(
      query: query,
      cityName: cityName,
      weatherApiKey: weatherApiKey,
    );

    final enabled =
        _prefs.getBool(AppConstants.prefsRainMonitorEnabled) ?? true;
    if (!enabled) {
      _printStatus(source, cityName, 'Rain monitor is disabled in settings.');
      return;
    }

    final now = DateTime.now();
    final rainStart = _nextRainWithin(hourlyForecast, now, lookAhead);

    if (rainStart == null) {
      _printStatus(
        source,
        cityName,
        'No rain expected in the next 20 minutes.',
      );
      await _prefs.remove(rainEventIsoKey);
      await _prefs.remove(rainEventCityKey);
      return;
    }

    final expectedIso = rainStart.time.toIso8601String();
    final savedIso = _prefs.getString(rainEventIsoKey);
    final savedCity = _prefs.getString(rainEventCityKey);
    if (savedIso == expectedIso && savedCity == cityName) {
      _printStatus(source, cityName, 'Rain alert already sent for this event.');
      return;
    }

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final granted = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
      if (!granted) {
        _printStatus(source, cityName, 'Notification permission not granted.');
        return;
      }
    }

    final minutesUntilRain = rainStart.time
        .difference(now)
        .inMinutes
        .clamp(0, 20);
    final body = minutesUntilRain <= 1
        ? 'Rain is expected any minute now in $cityName.'
        : 'Rain is expected in about $minutesUntilRain minutes in $cityName.';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: rainAlertNotificationId,
        channelKey: rainAlertChannelKey,
        title: 'Rain is coming soon',
        body: body,
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
    );

    await _prefs.setString(rainEventIsoKey, expectedIso);
    await _prefs.setString(rainEventCityKey, cityName);

    _printStatus(
      source,
      cityName,
      'Rain detected within 20 minutes. Alert sent.',
    );
  }

  HourlyForecast? _nextRainWithin(
    List<HourlyForecast> hourlyForecast,
    DateTime now,
    Duration lookAhead,
  ) {
    final end = now.add(lookAhead);
    final sorted = [...hourlyForecast]
      ..sort((a, b) => a.time.compareTo(b.time));

    for (final hour in sorted) {
      if (hour.time.isAfter(now) &&
          !hour.time.isAfter(end) &&
          _isRain(hour.conditionText)) {
        return hour;
      }
    }
    return null;
  }

  bool _isRain(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('rain') ||
        normalized.contains('drizzle') ||
        normalized.contains('shower') ||
        normalized.contains('thunder') ||
        normalized.contains('sleet');
  }

  void _printStatus(String source, String cityName, String message) {
    if (kDebugMode) {
      debugPrint('[RainMonitor][$source][$cityName] $message');
    }
  }
}
