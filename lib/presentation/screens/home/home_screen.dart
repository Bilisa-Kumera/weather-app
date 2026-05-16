import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/utils/weather_gradient.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/forecast.dart';
import '../../../domain/entities/weather.dart';
import '../../../core/services/location_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/city/city_bloc.dart';
import '../../bloc/weather/weather_bloc.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/weather_icon.dart';
import '../../widgets/state/empty_state_view.dart';
import '../../widgets/state/error_state_view.dart';
import '../../widgets/state/loading_state_view.dart';
import '../details/weather_detail_screen.dart';
import '../settings/settings_screen.dart';

const List<Map<String, Object>> _quickCities = [
  {
    'name': 'Addis Ababa',
    'country': 'Ethiopia',
    'lat': 9.145,
    'lon': 38.7319,
    'icon': Icons.location_city,
  },
  {
    'name': 'Adama',
    'country': 'Ethiopia',
    'lat': 8.54,
    'lon': 39.27,
    'icon': Icons.apartment,
  },
  {
    'name': 'Jimma',
    'country': 'Ethiopia',
    'lat': 7.67,
    'lon': 36.83,
    'icon': Icons.park,
  },
  {
    'name': 'Bishoftu',
    'country': 'Ethiopia',
    'lat': 8.75,
    'lon': 38.98,
    'icon': Icons.local_florist,
  },
  {
    'name': 'Shashamane',
    'country': 'Ethiopia',
    'lat': 7.20,
    'lon': 38.60,
    'icon': Icons.terrain,
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final city = context.read<CityBloc>().state.selectedCity;
    if (city != null) {
      context.read<WeatherBloc>().add(LoadWeather(_queryFor(city)));
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPaintBaselinesEnabled = false;
      return true;
    }());
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CityBloc, CityState>(
      listenWhen: (previous, current) => previous.selectedCity != current.selectedCity,
      listener: (context, state) {
        final city = state.selectedCity;
        if (city != null) {
          context.read<WeatherBloc>().add(LoadWeather(_queryFor(city)));
        }
      },
      child: BlocBuilder<CityBloc, CityState>(
        builder: (context, cityState) {
          final city = cityState.selectedCity;
          if (city == null) {
            return EmptyStateView(message: l10n.noCitySelected);
          }

          return BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state.status == WeatherStatus.loading) {
                return LoadingStateView(message: l10n.loadingWeather);
              }
              if (state.status == WeatherStatus.failure) {
                return ErrorStateView(
                  message: state.message ?? l10n.weatherFetchError,
                  onRetry: () =>
                      context.read<WeatherBloc>().add(LoadWeather(_queryFor(city))),
                );
              }

              final weather = state.weather;
              final forecast = state.forecast;
              if (weather == null || forecast == null) {
                return EmptyStateView(message: l10n.noWeatherData);
              }

              final selectedDay = _resolveSelectedDay(
                state.selectedDate,
                forecast,
                state.history,
              );
              final today = DateTime.now();
              final todayHourly = forecast.hourly
                  .where((hour) => _isSameDay(hour.time, today))
                  .toList()
                ..sort((a, b) => a.time.compareTo(b.time));

              final colors = WeatherGradient.forCondition(
                condition: selectedDay?.conditionText ?? weather.conditionText,
                isDay: weather.isDay,
              );

              return GradientBackground(
                colors: colors,
                child: SafeArea(
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(decoration: TextDecoration.none),
                    child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<WeatherBloc>().add(RefreshWeather(_queryFor(city)));
                    },
                    child: ListView(
                      padding: EdgeInsets.all(r.w(20)),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _openCityPicker(context, colors),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white),
                                  SizedBox(width: r.w(6)),
                                  Text(
                                    weather.city,
                                    style: TextStyle(
                                      fontSize: r.sp(14),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.settings, color: Colors.white, size: r.w(22)),
                            ),
                          ],
                        ),
                        SizedBox(height: r.h(16)),
                        GestureDetector(
                          onTap: selectedDay == null
                              ? null
                              : () => _openDetail(
                                    context,
                                    weather,
                                    forecast,
                                    selectedDay,
                                    state.history,
                                  ),
                          child: _FrostedCard(
                            borderRadius: r.r(24),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                              children: [
                                SizedBox(height: r.h(8)),
                                WeatherIcon(url: weather.conditionIconUrl, size: r.w(56)),
                                SizedBox(height: r.h(12)),
                                Text(
                                  '${weather.tempC.toStringAsFixed(0)}\u00B0C',
                                  style: TextStyle(
                                    fontSize: r.sp(52),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _conditionInAfaanOromoo(context, weather.conditionText),
                                  style: TextStyle(
                                    fontSize: r.sp(16),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: r.h(6)),
                                Text(
                                  '${l10n.high}: ${selectedDay?.maxTempC.toStringAsFixed(0) ?? '--'}\u00B0C  -  ${l10n.low}: ${selectedDay?.minTempC.toStringAsFixed(0) ?? '--'}\u00B0C',
                                  style: TextStyle(
                                    fontSize: r.sp(12),
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                ),
                                SizedBox(height: r.h(12)),
                              ],
                            ),
                          ),
                        ),
                        ),
                        SizedBox(height: r.h(16)),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallStatCard(
                                title: l10n.humidity,
                                value: '${weather.humidity}% ',
                                icon: Icons.water_drop_outlined,
                              ),
                            ),
                            SizedBox(width: r.w(12)),
                            Expanded(
                              child: _SmallStatCard(
                                title: 'Qilleensa',
                                value: '${weather.windKph.toStringAsFixed(0)} km/h',
                                icon: Icons.air,
                              ),
                            ),
                            SizedBox(width: r.w(12)),
                            Expanded(
                              child: _SmallStatCard(
                                title: 'UV',
                                value: weather.uv.toStringAsFixed(0),
                                icon: Icons.wb_sunny_outlined,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.h(20)),
                        Text(
                          l10n.todayHours,
                          style: TextStyle(
                            fontSize: r.sp(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: r.h(12)),
                        todayHourly.isEmpty
                            ? _FrostedCard(
                                borderRadius: r.r(18),
                                child: Padding(
                                  padding: EdgeInsets.all(r.w(14)),
                                  child: Text(
                                    l10n.noHourlyData,
                                    style: TextStyle(
                                      fontSize: r.sp(12),
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: r.h(120),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: todayHourly.length,
                                  separatorBuilder: (_, __) => SizedBox(width: r.w(12)),
                                  itemBuilder: (context, index) {
                                    final hour = todayHourly[index];
                                    return _FrostedCard(
                                      borderRadius: r.r(18),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: r.w(14),
                                          vertical: r.h(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _hourLabel(hour.time),
                                              style: TextStyle(
                                                fontSize: r.sp(12),
                                                color: Colors.white70,
                                              ),
                                            ),
                                            SizedBox(height: r.h(8)),
                                            WeatherIcon(url: hour.conditionIconUrl, size: r.w(32)),
                                            SizedBox(height: r.h(8)),
                                            Text(
                                              '${hour.tempC.toStringAsFixed(0)}\u00B0C',
                                              style: TextStyle(
                                                fontSize: r.sp(14),
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        SizedBox(height: r.h(20)),
                        Text(
                          l10n.weeklyForecast,
                          style: TextStyle(
                            fontSize: r.sp(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: r.h(12)),
                        SizedBox(
                          height: r.h(150),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: forecast.daily.length,
                            separatorBuilder: (_, __) => SizedBox(width: r.w(12)),
                            itemBuilder: (context, index) {
                              final day = forecast.daily[index];
                              return GestureDetector(
                                onTap: () => _openDetail(
                                  context,
                                  weather,
                                  forecast,
                                  day,
                                  state.history,
                                ),
                                child: _FrostedCard(
                                  borderRadius: r.r(18),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: r.w(14),
                                      vertical: r.h(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _dayLabel(context, day.date),
                                          style: TextStyle(
                                            fontSize: r.sp(12),
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                        SizedBox(height: r.h(8)),
                                        WeatherIcon(url: day.conditionIconUrl, size: r.w(36)),
                                        SizedBox(height: r.h(8)),
                                        Text(
                                          '${day.maxTempC.toStringAsFixed(0)}\u00B0C',
                                          style: TextStyle(
                                            fontSize: r.sp(14),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '${day.minTempC.toStringAsFixed(0)}\u00B0C',
                                          style: TextStyle(
                                            fontSize: r.sp(12),
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: r.h(20)),
                        SizedBox(height: r.h(24)),
                      ],
                    ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _queryFor(City city) => '${city.lat},${city.lon}';

  DailyForecast? _resolveSelectedDay(
    DateTime selected,
    Forecast forecast,
    List<DailyForecast> history,
  ) {
    for (final day in forecast.daily) {
      if (_isSameDay(day.date, selected)) {
        return day;
      }
    }
    for (final day in history) {
      if (_isSameDay(day.date, selected)) {
        return day;
      }
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }


  String _hourLabel(DateTime time) {
    final hour = time.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }


  String _conditionInAfaanOromoo(BuildContext context, String condition) {
    if (Localizations.localeOf(context).languageCode != 'om') return condition;
    final c = condition.toLowerCase();

    if (c.contains('thundery outbreaks possible') ||
        c.contains('patchy light rain with thunder') ||
        c.contains('moderate or heavy rain with thunder') ||
        c.contains('thunder')) {
      return 'Roobaa fi bakakkaa';
    }

    if (c.contains('blizzard') || c.contains('blowing snow')) return 'Qilleensa cabbii cimaa';
    if (c.contains('heavy snow')) return 'Cabbiin cimaa';
    if (c.contains('patchy heavy snow')) return 'Cabbiin cimaa bakka-bakkaatti';
    if (c.contains('light snow') || c.contains('patchy snow')) return 'Cabbiin salphaa';
    if (c.contains('sleet') || c.contains('ice pellets') || c.contains('freezing')) return 'Cabbiin makamaa';
    if (c.contains('snow')) return 'Cabbiin';

    if (c.contains('torrential rain shower') || c.contains('violent rain')) return 'Roobni baayyee cimaa';
    if (c.contains('moderate or heavy rain shower')) return 'Rooba dhiqannaa cimaa';
    if (c.contains('light rain shower')) return 'Rooba dhiqannaa salphaa';
    if (c.contains('patchy rain nearby')) return 'Rooba bakka-bakkaatti dhihoo';
    if (c.contains('heavy rain')) return 'Rooba cimaa';
    if (c.contains('moderate rain')) return 'Rooba giddugaleessaa';
    if (c.contains('light rain') || c.contains('drizzle') || c.contains('patchy light drizzle')) return 'Rooba salphaa';
    if (c.contains('patchy light rain')) return 'Rooba salphaa bakka-bakkaatti';
    if (c.contains('rain shower') || c.contains('showers')) return 'Rooba dhiqannaa';
    if (c.contains('rain')) return 'Rooba';

    if (c.contains('freezing fog') || c.contains('fog') || c.contains('mist')) return 'Awwaara';
    if (c.contains('overcast')) return 'Duumessa guutuu';
    if (c.contains('partly cloudy') || c.contains('partly')) return 'Gariin duumeessa';
    if (c.contains('cloudy') || c.contains('cloud')) return 'Duumessa';

    if (c.contains('clear')) return 'Ifa';
    if (c.contains('sunny')) return 'Aduun ifte';

    return condition;
  }
  void _openDetail(
    BuildContext context,
    Weather weather,
    Forecast forecast,
    DailyForecast selected,
    List<DailyForecast> history,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: WeatherDetailScreen(
            weather: weather,
            forecast: forecast,
            selected: selected,
            history: history,
          ),
        ),
      ),
    );
  }

  Future<void> _openCityPicker(BuildContext context, List<Color> colors) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: _CityPickerScreen(colors: colors),
        ),
      ),
    );
  }
}
class _CityPickerScreen extends StatelessWidget {
  const _CityPickerScreen({required this.colors});

  final List<Color> colors;

  
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      colors: colors,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(r.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button & Title
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(r.r(12)),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          iconSize: r.sp(20),
                        ),
                      ),
                      SizedBox(width: r.w(12)),
                      Expanded(
                        child: Text(
                          l10n.selectCity,
                          style: TextStyle(
                            fontSize: r.sp(22),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.h(24)),

                  // Hero Section with Location Icon
                  Center(
                    child: Container(
                      width: r.w(120),
                      height: r.w(120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_pin,
                        size: r.sp(60),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: r.h(24)),

                  // Subtitle
                  Center(
                    child: Text(
                      l10n.selectLocation,
                      style: TextStyle(
                        fontSize: r.sp(16),
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  SizedBox(height: r.h(32)),

                  // Main Search Card
                  _FrostedCard(
                    borderRadius: r.r(28),
                    child: Padding(
                      padding: EdgeInsets.all(r.w(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Title
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(r.w(8)),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D4ED8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(r.r(10)),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: const Color(0xFF1D4ED8),
                                  size: r.sp(20),
                                ),
                              ),
                              SizedBox(width: r.w(12)),
                              Text(
                                l10n.selectLocation,
                                style: TextStyle(
                                  fontSize: r.sp(16),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: r.h(20)),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: r.w(12)),
                                child: Text(
                                  l10n.or,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: r.sp(12),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          SizedBox(height: r.h(20)),

                          // Current Location Button
                          _AnimatedButton(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              try {
                                final locationService = LocationService();
                                
                                final serviceEnabled = await Geolocator.isLocationServiceEnabled();
                                if (!serviceEnabled) {
                                  final shouldOpenSettings = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(l10n.locationServiceTitle),
                                      content: Text(l10n.locationServicesDisabled),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(l10n.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text(l10n.enable),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (shouldOpenSettings == true) {
                                    await Geolocator.openLocationSettings();
                                  }
                                  return;
                                }
                                
                                // Check permission
                                final hasPermission = await locationService.requestPermission();
                                if (!hasPermission) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.locationPermissionDenied),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                
                                final city = await locationService.getCurrentCity();
                                if (city != null) {
                                  context.read<CityBloc>().add(SelectCity(city));
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.currentLocationError),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.errorDetails(e.toString())),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: r.h(14)),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1D4ED8),
                                    const Color(0xFF3B82F6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(r.r(16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1D4ED8).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                    size: r.sp(20),
                                  ),
                                  SizedBox(width: r.w(8)),
                                  Text(
                                    l10n.currentLocation,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: r.sp(15),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: r.h(12)),

                          // Pick from Map Button
                          _AnimatedButton(
                            onTap: () => _openMapPicker(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: r.h(14)),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(r.r(16)),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map,
                                    color: const Color(0xFF1D4ED8),
                                    size: r.sp(20),
                                  ),
                                  SizedBox(width: r.w(8)),
                                  Text(
                                    l10n.pickFromMap,
                                    style: TextStyle(
                                      color: const Color(0xFF1D4ED8),
                                      fontSize: r.sp(15),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: r.h(24)),

                  // Quick Select Section
                  Text(
                    l10n.popularCities,
                    style: TextStyle(
                      fontSize: r.sp(16),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: r.h(16)),

                  // Quick Select Chips
                  Wrap(
                    spacing: r.w(10),
                    runSpacing: r.h(10),
                    children: _quickCities.map((city) {
                      return _AnimatedButton(
                        onTap: () {
                          // Create City object and select
                          final selectedCity = City(
                            name: city['name'] as String,
                            country: city['country'] as String,
                            lat: city['lat'] as double,
                            lon: city['lon'] as double,
                          );
                          context.read<CityBloc>().add(SelectCity(selectedCity));
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.w(14),
                            vertical: r.h(10),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(r.r(20)),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                city['icon'] as IconData,
                                color: Colors.white,
                                size: r.sp(16),
                              ),
                              SizedBox(width: r.w(6)),
                              Text(
                                city['name'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: r.sp(13),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: r.h(32)),

                  // Footer Info
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.w(16),
                        vertical: r.h(8),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.r(20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withOpacity(0.8),
                            size: r.sp(14),
                          ),
                          SizedBox(width: r.w(6)),
                          Text(
                            l10n.citySelectionInfo,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: r.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMapPicker(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _MapPickerScreen(),
      ),
    );
  }
}

class _MapPickerScreen extends StatefulWidget {
  const _MapPickerScreen();

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapPickerTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirmLocation,
              child: Text(
                l10n.confirm,
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation ?? const LatLng(9.145, 38.7319), // Use current location or Addis Ababa as fallback
          initialZoom: 10.0,
          onTap: _onMapTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.weatherapp',
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  Future<void> _confirmLocation() async {
    if (_selectedLocation == null) return;

    // Use LocationService to reverse geocode
    final locationService = LocationService();
    final city = await locationService.reverseGeocode(
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
    );

    if (city != null && mounted) {
      context.read<CityBloc>().add(SelectCity(city));
      Navigator.of(context).pop();
    } else {
      // Fallback: create a city with coordinates only
      final fallbackCity = City(
        name: '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
        country: 'Unknown',
        lat: _selectedLocation!.latitude,
        lon: _selectedLocation!.longitude,
      );
      if (mounted) {
        context.read<CityBloc>().add(SelectCity(fallbackCity));
        Navigator.of(context).pop();
      }
    }
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButton({required this.child, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _FrostedCard extends StatelessWidget {
  const _FrostedCard({required this.child, required this.borderRadius});

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return _FrostedCard(
      borderRadius: r.r(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(12)),
        child: Column(
          children: [
            Icon(icon, size: r.w(18), color: Colors.white.withOpacity(0.9)),
            SizedBox(height: r.h(6)),
            Text(
              title,
              style: TextStyle(fontSize: r.sp(11), color: Colors.white70),
            ),
            SizedBox(height: r.h(4)),
            Text(
              value,
              style: TextStyle(
                fontSize: r.sp(12),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _dayLabel(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context);
  if (locale.languageCode == 'om') {
    const labels = ['Wiixata', 'Qibxata', 'Roobii', 'Kamiisa', 'Jimaata', 'Sanbata', 'Dilbata'];
    return labels[date.weekday - 1];
  }
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}

