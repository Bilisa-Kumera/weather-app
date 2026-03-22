import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/utils/weather_gradient.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/forecast.dart';
import '../../../domain/entities/weather.dart';
import '../../bloc/city/city_bloc.dart';
import '../../bloc/weather/weather_bloc.dart';
import '../../widgets/common/city_dropdown.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/weather_icon.dart';
import '../../widgets/state/empty_state_view.dart';
import '../../widgets/state/error_state_view.dart';
import '../../widgets/state/loading_state_view.dart';
import '../details/weather_detail_screen.dart';
import '../settings/settings_screen.dart';

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
            return const EmptyStateView(message: 'Itti fufuuf magaalaa filadhu.');
          }

          return BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state.status == WeatherStatus.loading) {
                return const LoadingStateView(message: 'Tilmaama haaraa fe\'aa jira...');
              }
              if (state.status == WeatherStatus.failure) {
                return ErrorStateView(
                  message: state.message ?? 'Haala qilleensaa fe\'uu hin dandeenye',
                  onRetry: () =>
                      context.read<WeatherBloc>().add(LoadWeather(_queryFor(city))),
                );
              }

              final weather = state.weather;
              final forecast = state.forecast;
              if (weather == null || forecast == null) {
                return const EmptyStateView(message: 'Daataan haala qilleensaa amma hin jiru.');
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
                                  _conditionInAfaanOromoo(weather.conditionText),
                                  style: TextStyle(
                                    fontSize: r.sp(16),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: r.h(6)),
                                Text(
                                  'Ol: ${selectedDay?.maxTempC.toStringAsFixed(0) ?? '--'}\u00B0C  -  Gadi: ${selectedDay?.minTempC.toStringAsFixed(0) ?? '--'}\u00B0C',
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
                                title: 'Jiidhina',
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
                          "Sa'aatii har'a",
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
                                    'Daataan sa\'aatii har\'aa amma hin jiru.',
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
                          'Tilmaama Torban',
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
                                          _dayLabel(day.date),
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


  String _conditionInAfaanOromoo(String condition) {
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

    return GradientBackground(
      colors: colors,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(r.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                    SizedBox(width: r.w(4)),
                    Text(
                      'Magaalaa Filadhu',
                      style: TextStyle(
                        fontSize: r.sp(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: r.h(16)),
                _FrostedCard(
                  borderRadius: r.r(24),
                  child: Padding(
                    padding: EdgeInsets.all(r.w(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Magaalaa barbaadi fi fili',
                          style: TextStyle(
                            fontSize: r.sp(15),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: r.h(12)),
                        CityDropdown(
                          onSelected: (city) {
                            context.read<CityBloc>().add(SelectCity(city));
                            Navigator.of(context).pop();
                          },
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
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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

String _dayLabel(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}
