import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/forecast_model.dart';
import '../constants/app_constants.dart';
import 'rain_notification_service.dart';

const Duration _monitorInterval = Duration(minutes: 5);
const Duration _lookAheadWindow = Duration(minutes: 20);

Future<void> initializeRainBackgroundService({required bool enabled}) async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: enabled,
      onForeground: rainMonitorOnStart,
      onBackground: onIosRainMonitorBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: rainMonitorOnStart,
      autoStart: enabled,
      autoStartOnBoot: enabled,
      isForegroundMode: true,
      notificationChannelId: RainNotificationService.monitorChannelKey,
      initialNotificationTitle: 'Rain monitor active',
      initialNotificationContent: 'Checking rain every 5 minutes',
      foregroundServiceNotificationId:
          RainNotificationService.monitorServiceNotificationId,
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
  );

  final running = await service.isRunning();
  if (enabled && !running) {
    await service.startService();
  }
  if (!enabled && running) {
    await stopRainBackgroundMonitoring();
  }
}

Future<void> startRainBackgroundMonitoring() async {
  final service = FlutterBackgroundService();
  final running = await service.isRunning();
  if (!running) {
    await service.startService();
  }
}

Future<void> stopRainBackgroundMonitoring() async {
  final service = FlutterBackgroundService();
  service.invoke('stopService');
}

Future<bool> isRainBackgroundMonitoringRunning() async {
  return FlutterBackgroundService().isRunning();
}

@pragma('vm:entry-point')
Future<bool> onIosRainMonitorBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await _runRainCheck(source: 'ios_background');
  return true;
}

@pragma('vm:entry-point')
void rainMonitorOnStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((_) async {
    await service.stopSelf();
  });

  var busy = false;

  Future<void> tick(String source) async {
    if (busy) return;
    busy = true;

    try {
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: 'Rain monitor active',
          content:
              'Last check: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        );
      }
      await _runRainCheck(source: source);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RainMonitor][service] check failed: $e');
      }
    } finally {
      busy = false;
    }
  }

  tick('service_start');
  Timer.periodic(_monitorInterval, (_) => tick('service_periodic'));
}

Future<void> _runRainCheck({required String source}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  final enabled = prefs.getBool(AppConstants.prefsRainMonitorEnabled) ?? true;
  if (!enabled) {
    if (kDebugMode) {
      debugPrint('[RainMonitor][$source] Monitoring disabled by user.');
    }
    return;
  }

  final query = prefs.getString(RainNotificationService.rainQueryKey);
  final cityName = prefs.getString(RainNotificationService.rainCityKey);
  final apiKey = prefs.getString(RainNotificationService.weatherApiKeyPrefsKey);

  if (query == null || query.isEmpty || cityName == null || cityName.isEmpty) {
    if (kDebugMode) {
      debugPrint('[RainMonitor][$source] No saved city/query yet.');
    }
    return;
  }

  if (apiKey == null || apiKey.isEmpty) {
    if (kDebugMode) {
      debugPrint('[RainMonitor][$source][$cityName] Missing Weather API key.');
    }
    return;
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.weatherApiBaseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      queryParameters: {'key': apiKey},
    ),
  );

  final response = await dio.get(
    '/forecast.json',
    queryParameters: {'q': query, 'days': 2, 'aqi': 'no', 'alerts': 'no'},
  );

  final data = response.data;
  if (data is! Map) {
    if (kDebugMode) {
      debugPrint(
        '[RainMonitor][$source][$cityName] Unexpected forecast response.',
      );
    }
    return;
  }

  final forecast = ForecastModel.fromJson(
    Map<String, dynamic>.from(data),
  ).toEntity();
  final rainNotificationService = RainNotificationService(prefs);
  await rainNotificationService.initialize();
  await rainNotificationService.syncRainAlert(
    cityName: cityName,
    query: query,
    weatherApiKey: apiKey,
    hourlyForecast: forecast.hourly,
    lookAhead: _lookAheadWindow,
    source: source,
  );
}
