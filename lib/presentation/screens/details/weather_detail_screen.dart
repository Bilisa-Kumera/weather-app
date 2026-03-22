import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/utils/weather_gradient.dart';
import '../../../domain/entities/forecast.dart';
import '../../../domain/entities/weather.dart';
import '../../widgets/common/date_selector.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/weather_icon.dart';

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
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.selected.date.year,
      widget.selected.date.month,
      widget.selected.date.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final selectedDay = _selectedDayFor(_selectedDate);
    final gradientSource = selectedDay ?? widget.selected;
    final gradient = WeatherGradient.forCondition(
      condition: gradientSource.conditionText,
      isDay: _isDayFor(_selectedDate),
    );
    final hourly = _hourlyFor(_selectedDate);

    return GradientBackground(
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
            if (selectedDay == null)
              GlassCard(
                borderRadius: r.r(24),
                padding: EdgeInsets.all(r.w(18)),
                child: Text(
                  'Guyyaa kanaaf daataan haala qilleensaa amma hin jiru.',
                  style: TextStyle(
                    fontSize: r.sp(14),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              GlassCard(
                borderRadius: r.r(24),
                padding: EdgeInsets.all(r.w(18)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedDay.maxTempC.toStringAsFixed(0)}\u00B0C',
                            style: TextStyle(
                              fontSize: r.sp(52),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _conditionInAfaanOromoo(selectedDay.conditionText),
                            style: TextStyle(
                              fontSize: r.sp(16),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: r.h(6)),
                          Text(
                            'H: ${selectedDay.maxTempC.toStringAsFixed(0)}\u00B0C  -  L: ${selectedDay.minTempC.toStringAsFixed(0)}\u00B0C',
                            style: TextStyle(
                              fontSize: r.sp(13),
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    WeatherIcon(url: selectedDay.conditionIconUrl, size: r.w(72)),
                  ],
                ),
              ),
            SizedBox(height: r.h(20)),
            Text(
              'Guyyaa Filadhu',
              style: TextStyle(
                fontSize: r.sp(22),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: r.h(12)),
            DateSelector(
              selectedDate: _selectedDate,
              onSelected: (date) {
                setState(() {
                  _selectedDate = DateTime(date.year, date.month, date.day);
                });
              },
            ),
            SizedBox(height: r.h(20)),
            Text(
              'Tilmaama Sa\'aatii',
              style: TextStyle(
                fontSize: r.sp(22),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: r.h(12)),
            hourly.isEmpty
                ? GlassCard(
                    borderRadius: r.r(18),
                    padding: EdgeInsets.all(r.w(14)),
                    child: Text(
                      'Guyyaa kanaaf daataan sa\'aatii amma hin jiru.',
                      style: TextStyle(fontSize: r.sp(13), color: Colors.white70),
                    ),
                  )
                : SizedBox(
                    height: r.h(120),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hourly.length,
                      separatorBuilder: (_, __) => SizedBox(width: r.w(12)),
                      itemBuilder: (context, index) {
                        final hour = hourly[index];
                        return GlassCard(
                          borderRadius: r.r(18),
                          padding: EdgeInsets.all(r.w(12)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _hourLabel(hour.time),
                                style: TextStyle(fontSize: r.sp(12), color: Colors.white70),
                              ),
                              SizedBox(height: r.h(6)),
                              WeatherIcon(url: hour.conditionIconUrl, size: r.w(36)),
                              SizedBox(height: r.h(6)),
                              Text(
                                '${hour.tempC.toStringAsFixed(0)}\u00B0C',
                                style: TextStyle(
                                  fontSize: r.sp(14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: r.h(20)),
            Text(
              'Bal\'ina Haala Qilleensaa',
              style: TextStyle(
                fontSize: r.sp(22),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: r.h(12)),
            GlassCard(
              borderRadius: r.r(20),
              padding: EdgeInsets.all(r.w(16)),
              child: Column(
                children: [
                  _DetailRow(label: 'Ho\'ina', value: '${widget.weather.tempC.toStringAsFixed(0)}\u00B0C'),
                  _DetailRow(label: 'Jiidhina', value: '${widget.weather.humidity}%'),
                  _DetailRow(label: 'Qilleensa', value: '${widget.weather.windKph.toStringAsFixed(0)} km/h'),
                  _DetailRow(label: 'Indeeksii UV', value: widget.weather.uv.toStringAsFixed(1)),
                ],
              ),
            ),
            SizedBox(height: r.h(20)),
            Text(
              'Darbani 7 + Itti Aanan 7',
              style: TextStyle(
                fontSize: r.sp(22),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: r.h(12)),
            Column(
              children: _allDays.map((day) {
                final isSelected = _isSameDay(day.date, _selectedDate);
                return Padding(
                  padding: EdgeInsets.only(bottom: r.h(10)),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(day.date.year, day.date.month, day.date.day);
                      });
                    },
                    child: GlassCard(
                      borderRadius: r.r(18),
                      padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_dayLabel(day.date)} ${day.date.day}/${day.date.month}',
                              style: TextStyle(
                                fontSize: r.sp(13),
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          WeatherIcon(url: day.conditionIconUrl, size: r.w(30)),
                          SizedBox(width: r.w(12)),
                          Text(
                            '${day.maxTempC.toStringAsFixed(0)}\u00B0C / ${day.minTempC.toStringAsFixed(0)}\u00B0C',
                            style: TextStyle(
                              fontSize: r.sp(13),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  DailyForecast? _selectedDayFor(DateTime date) {
    for (final day in _allDays) {
      if (_isSameDay(day.date, date)) {
        return day;
      }
    }
    return null;
  }

  bool _isDayFor(DateTime date) {
    final hours = _hourlyFor(date);
    if (hours.isNotEmpty) {
      final nowHour = DateTime.now().hour;
      for (final hour in hours) {
        if (hour.time.hour == nowHour) {
          return hour.isDay;
        }
      }
      return hours.first.isDay;
    }
    return widget.weather.isDay;
  }
  List<HourlyForecast> _hourlyFor(DateTime date) {
    return widget.forecast.hourly.where((hour) {
      return _isSameDay(hour.time, date);
    }).toList();
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
    if (hour == 0) return 'Amma';
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
  String _dayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
