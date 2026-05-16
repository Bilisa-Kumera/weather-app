import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/weather_gradient.dart';
import '../../../domain/entities/forecast.dart';
import '../../../domain/entities/weather.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../bloc/locale/locale_cubit.dart';
import '../../widgets/common/date_selector.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/weather_icon.dart';
import 'ai_chat_screen.dart';

class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({
    super.key,
    required this.weather,
    required this.forecast,
    required this.selected,
    this.history = const [],
  });

  final Weather weather;
  final Forecast forecast;
  final DailyForecast selected;
  final List<DailyForecast> history;

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late final AIBloc _aiBloc;
  late DateTime _selectedDate;
  HourlyForecast? _selectedHour;
  String _lastSummaryPayload = '';

  @override
  void initState() {
    super.initState();
    _aiBloc = AIBloc(
      aiService: AIService(),
      locale: context.read<LocaleCubit>().state,
    );
    _selectedDate = DateTime(
      widget.selected.date.year,
      widget.selected.date.month,
      widget.selected.date.day,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSummaryIfNeeded(force: true);
    });
  }

  @override
  void dispose() {
    _aiBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;
    final selectedDay = _selectedDayFor(_selectedDate);
    final isHourMode = _selectedHour != null;

    final displayCondition =
        _selectedHour?.conditionText ?? selectedDay?.conditionText ?? widget.weather.conditionText;
    final displayIcon =
        _selectedHour?.conditionIconUrl ?? selectedDay?.conditionIconUrl ?? widget.weather.conditionIconUrl;
    final displayTemp = _selectedHour?.tempC ?? selectedDay?.maxTempC ?? widget.weather.tempC;

    final gradient = WeatherGradient.forCondition(
      condition: displayCondition,
      isDay: _selectedHour?.isDay ?? widget.weather.isDay,
    );

    return BlocProvider.value(
      value: _aiBloc,
      child: GradientBackground(
        colors: gradient,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white),
                SizedBox(width: r.w(6)),
                Text(
                  widget.weather.city,
                  style: TextStyle(color: Colors.white, fontSize: r.sp(16)),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(r.w(20)),
            children: [
              Text(
                l10n.weatherSummary,
                style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.h(12)),
              GlassCard(
                borderRadius: r.r(24),
                padding: EdgeInsets.all(r.w(18)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        WeatherIcon(url: displayIcon, size: r.w(64)),
                        SizedBox(width: r.w(14)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _topLine(
                                context,
                                label: l10n.temperatureLabel,
                                value: '${displayTemp.toStringAsFixed(0)}\u00B0C',
                              ),
                              _topLine(
                                context,
                                label: l10n.conditionLabel,
                                value: _conditionInAfaanOromoo(displayCondition),
                              ),
                              _topLine(
                                context,
                                label: l10n.timeDayLabel,
                                value: isHourMode
                                    ? '${_dayName(_selectedDate)} ${_hourLabel(_selectedHour!.time)}'
                                    : '${_dayName(_selectedDate)} ${_selectedDate.day}/${_selectedDate.month}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: r.h(10)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isHourMode
                            ? l10n.showingHourInfo
                            : l10n.showingDayInfo,
                        style: TextStyle(fontSize: r.sp(12), color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.h(18)),
              Text(
                l10n.detailedInfo,
                style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.h(12)),
              GlassCard(
                borderRadius: r.r(20),
                padding: EdgeInsets.all(r.w(16)),
                child: Column(
                  children: [
                    _DetailRow(
                      label: l10n.humidityLabel,
                      value: '${_humidityValue(selectedDay)}%',
                    ),
                    _DetailRow(
                      label: l10n.windLabel,
                      value: '${_windValue(selectedDay).toStringAsFixed(0)} km/h',
                    ),
                    _DetailRow(
                      label: l10n.feelsLikeLabel,
                      value: '${_feelsLikeValue(selectedDay).toStringAsFixed(0)}\u00B0C',
                    ),
                    _DetailRow(
                      label: l10n.rainChanceLabel,
                      value: '${_rainChanceFor(displayCondition)}%',
                    ),
                    _DetailRow(
                      label: l10n.pressureLabel,
                      value: '${widget.weather.pressureMb.toStringAsFixed(0)} mb',
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.h(18)),
              Text(
                l10n.selectDay,
                style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.h(12)),
              DateSelector(
                selectedDate: _selectedDate,
                onSelected: (date) {
                  setState(() {
                    _selectedDate = DateTime(date.year, date.month, date.day);
                    _selectedHour = null;
                  });
                  _generateSummaryIfNeeded(force: true);
                },
              ),
              SizedBox(height: r.h(18)),
              Text(
                l10n.dayHours,
                style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.h(12)),
              _buildHourlySection(r),
              SizedBox(height: r.h(18)),
              Text(
                l10n.selectedDays,
                style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.h(12)),
              _buildDailySection(r),
              SizedBox(height: r.h(18)),
              Text(
                l10n.aiSummary,
                style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.h(12)),
              _buildAiSection(r),
              SizedBox(height: r.h(14)),
              SizedBox(
                height: r.h(50),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: _aiBloc,
                          child: AIChatScreen(
                            cityName: widget.weather.city,
                            initialWeatherData: _buildWeatherPayload(),
                            themeColors: gradient,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.r(16)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.chatWithAi,
                    style: TextStyle(
                      fontSize: r.sp(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: r.h(18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiSection(Responsive r) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AIBloc, AIState>(
      builder: (context, state) {
        String? summary;
        String? error;
        var loading = false;

        if (state is AISuccess) {
          summary = state.summary;
        } else if (state is AILoading && !state.fromChat) {
          loading = true;
          summary = state.previousSummary;
        } else if (state is AIError) {
          error = state.message;
          summary = state.previousSummary;
        }

        return GlassCard(
          borderRadius: r.r(20),
          padding: EdgeInsets.all(r.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading) ...[
                const _AiLoadingIndicator(),
                SizedBox(height: r.h(10)),
              ],
              if (summary != null && summary.trim().isNotEmpty)
                Text(
                  summary,
                  style: TextStyle(
                    fontSize: r.sp(14),
                    color: Colors.white,
                    height: 1.4,
                  ),
                )
              else if (!loading)
                Text(
                  l10n.aiSummaryPlaceholder,
                  style: TextStyle(fontSize: r.sp(13), color: Colors.white70),
                ),
              if (error != null) ...[
                SizedBox(height: r.h(10)),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: r.sp(12),
                    color: const Color(0xFFFECACA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.h(10)),
                TextButton.icon(
                  onPressed: () => _generateSummaryIfNeeded(force: true),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    l10n.retry,
                    style: TextStyle(color: Colors.white, fontSize: r.sp(13)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourlySection(Responsive r) {
    final hourly = _hourlyFor(_selectedDate);
    if (hourly.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return GlassCard(
        borderRadius: r.r(18),
        padding: EdgeInsets.all(r.w(14)),
        child: Text(
          l10n.noHourlyData,
          style: TextStyle(fontSize: r.sp(13), color: Colors.white70),
        ),
      );
    }

    return SizedBox(
      height: r.h(122),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, __) => SizedBox(width: r.w(10)),
        itemBuilder: (context, index) {
          final hour = hourly[index];
          final selected = _selectedHour?.time == hour.time;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedHour = hour;
              });
              _generateSummaryIfNeeded(force: true);
            },
            child: GlassCard(
              borderRadius: r.r(18),
              padding: EdgeInsets.symmetric(horizontal: r.w(14), vertical: r.h(12)),
              child: Container(
                decoration: selected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(r.r(12)),
                        border: Border.all(color: Colors.white, width: 1.1),
                      )
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.w(4), vertical: r.h(2)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _hourLabel(hour.time),
                        style: TextStyle(fontSize: r.sp(12), color: Colors.white70),
                      ),
                      SizedBox(height: r.h(6)),
                      WeatherIcon(url: hour.conditionIconUrl, size: r.w(32)),
                      SizedBox(height: r.h(6)),
                      Text(
                        '${hour.tempC.toStringAsFixed(0)}\u00B0C',
                        style: TextStyle(
                          fontSize: r.sp(13),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailySection(Responsive r) {
    final allDays = _allDays;

    return Column(
      children: allDays.map((day) {
        final selected = _isSameDay(day.date, _selectedDate) && _selectedHour == null;

        return Padding(
          padding: EdgeInsets.only(bottom: r.h(10)),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = DateTime(day.date.year, day.date.month, day.date.day);
                _selectedHour = null;
              });
              _generateSummaryIfNeeded(force: true);
            },
            child: GlassCard(
              borderRadius: r.r(18),
              padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_dayName(day.date)} ${day.date.day}/${day.date.month}',
                      style: TextStyle(
                        fontSize: r.sp(13),
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  WeatherIcon(url: day.conditionIconUrl, size: r.w(30)),
                  SizedBox(width: r.w(12)),
                  Text(
                    '${day.maxTempC.toStringAsFixed(0)}\u00B0C / ${day.minTempC.toStringAsFixed(0)}\u00B0C',
                    style: TextStyle(fontSize: r.sp(13), color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _generateSummaryIfNeeded({bool force = false}) {
    if (!mounted) return;
    final payload = _buildWeatherPayload();

    if (!force && payload == _lastSummaryPayload) {
      return;
    }

    _lastSummaryPayload = payload;
    _aiBloc.add(GenerateWeatherSummary(weatherData: payload));
  }

  String _buildWeatherPayload() {
    final l10n = AppLocalizations.of(context)!;
    final selectedDay = _selectedDayFor(_selectedDate);
    final sourceCondition =
        _selectedHour?.conditionText ?? selectedDay?.conditionText ?? widget.weather.conditionText;

    final sourceTemp = _selectedHour?.tempC ?? selectedDay?.maxTempC ?? widget.weather.tempC;

    return [
      '${l10n.city}: ${widget.weather.city}, ${widget.weather.country}',
      '${l10n.timeDayLabel}: ${_selectedHour != null ? _hourLabel(_selectedHour!.time) : _dayName(_selectedDate)}',
      '${l10n.conditionLabel}: ${_conditionInAfaanOromoo(sourceCondition)} ($sourceCondition)',
      '${l10n.temperatureLabel}: ${sourceTemp.toStringAsFixed(1)}\u00B0C',
      '${l10n.feelsLikeLabel}: ${_feelsLikeValue(selectedDay).toStringAsFixed(1)}\u00B0C',
      '${l10n.humidityLabel}: ${_humidityValue(selectedDay)}${l10n.percent}',
      '${l10n.windLabel}: ${_windValue(selectedDay).toStringAsFixed(1)} ${l10n.kmh}',
      '${l10n.rainChanceLabel}: ${_rainChanceFor(sourceCondition)}${l10n.percent}',
      '${l10n.pressureLabel}: ${widget.weather.pressureMb.toStringAsFixed(1)} mb',
    ].join('\n');
  }

  int _humidityValue(DailyForecast? selectedDay) {
    if (_selectedHour != null) {
      return widget.weather.humidity;
    }
    return selectedDay?.avgHumidity ?? widget.weather.humidity;
  }

  double _windValue(DailyForecast? selectedDay) {
    if (_selectedHour != null) {
      return widget.weather.windKph;
    }
    return selectedDay?.maxWindKph ?? widget.weather.windKph;
  }

  double _feelsLikeValue(DailyForecast? selectedDay) {
    if (_selectedHour != null) {
      return widget.weather.feelsLikeC;
    }
    if (selectedDay != null) {
      return (selectedDay.maxTempC + selectedDay.minTempC) / 2;
    }
    return widget.weather.feelsLikeC;
  }

  int _rainChanceFor(String conditionText) {
    final c = conditionText.toLowerCase();
    if (c.contains('thunder')) return 90;
    if (c.contains('heavy rain')) return 85;
    if (c.contains('moderate rain')) return 70;
    if (c.contains('rain') || c.contains('drizzle') || c.contains('shower')) return 60;
    if (c.contains('cloud')) return 25;
    return 10;
  }

  DailyForecast? _selectedDayFor(DateTime date) {
    for (final day in _allDays) {
      if (_isSameDay(day.date, date)) {
        return day;
      }
    }
    return null;
  }

  List<HourlyForecast> _hourlyFor(DateTime date) {
    final items = widget.forecast.hourly.where((hour) => _isSameDay(hour.time, date)).toList();
    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  List<DailyForecast> get _allDays {
    final byDate = <String, DailyForecast>{};

    for (final day in widget.history) {
      byDate[_dateKey(day.date)] = day;
    }
    for (final day in widget.forecast.daily) {
      byDate[_dateKey(day.date)] = day;
    }

    final merged = byDate.values.toList();
    merged.sort((a, b) => a.date.compareTo(b.date));
    return merged;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _hourLabel(DateTime time) {
    final hour = time.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  String _dayName(DateTime date) {
    if (Localizations.localeOf(context).languageCode == 'om') {
      const labels = ['Wiixata', 'Qibxata', 'Roobii', 'Kamiisa', 'Jimaata', 'Sanbata', 'Dilbata'];
      return labels[date.weekday - 1];
    }
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }

  String _conditionInAfaanOromoo(String condition) {
    if (Localizations.localeOf(context).languageCode != 'om') return condition;
    final c = condition.toLowerCase();

    if (c.contains('thunder')) return 'Roobaa fi bakakkaa';
    if (c.contains('heavy rain')) return 'Rooba cimaa';
    if (c.contains('moderate rain')) return 'Rooba giddugaleessaa';
    if (c.contains('light rain') || c.contains('drizzle')) return 'Rooba salphaa';
    if (c.contains('rain shower') || c.contains('showers')) return 'Rooba dhiqannaa';
    if (c.contains('rain')) return 'Rooba';

    if (c.contains('fog') || c.contains('mist')) return 'Awwaara';
    if (c.contains('overcast')) return 'Duumessa guutuu';
    if (c.contains('partly cloudy') || c.contains('partly')) return 'Gariin duumeessa';
    if (c.contains('cloudy') || c.contains('cloud')) return 'Duumessa';

    if (c.contains('clear')) return 'Ifa';
    if (c.contains('sunny')) return 'Aduun ifte';

    return condition;
  }

  Widget _topLine(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final r = context.responsive;
    return Padding(
      padding: EdgeInsets.only(bottom: r.h(4)),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: r.sp(13),
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: r.sp(13),
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.h(6)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: r.sp(13),
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: r.sp(13),
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiLoadingIndicator extends StatelessWidget {
  const _AiLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        SizedBox(
          width: r.w(18),
          height: r.w(18),
          child: const CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        ),
        SizedBox(width: r.w(10)),
        Text(
          l10n.aiPreparing,
          style: TextStyle(
            fontSize: r.sp(13),
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
