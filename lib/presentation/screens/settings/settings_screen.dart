import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/rain_background_service.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/locale/locale_cubit.dart';
import '../../bloc/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rainMonitorEnabled = true;
  bool _isSavingRainMonitor = false;

  @override
  void initState() {
    super.initState();
    _loadRainMonitorSetting();
  }

  Future<void> _loadRainMonitorSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(AppConstants.prefsRainMonitorEnabled) ?? true;
    if (!mounted) return;
    setState(() {
      _rainMonitorEnabled = enabled;
    });
  }

  Future<void> _setRainMonitorEnabled(bool enabled) async {
    setState(() {
      _isSavingRainMonitor = true;
      _rainMonitorEnabled = enabled;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefsRainMonitorEnabled, enabled);

      if (enabled) {
        await startRainBackgroundMonitoring();
      } else {
        await stopRainBackgroundMonitoring();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingRainMonitor = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: EdgeInsets.all(r.w(20)),
        children: [
          Text(
            l10n.language,
            style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w600),
          ),
          SizedBox(height: r.h(12)),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.r(16)),
            ),
            child: Column(
              children: [
                RadioListTile<Locale>(
                  value: const Locale('om'),
                  groupValue: context.watch<LocaleCubit>().state,
                  title: Text(l10n.afaanOromoo),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<LocaleCubit>().setLocale(value);
                  },
                ),
                RadioListTile<Locale>(
                  value: const Locale('en'),
                  groupValue: context.watch<LocaleCubit>().state,
                  title: Text(l10n.english),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<LocaleCubit>().setLocale(value);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: r.h(24)),
          Text(
            l10n.theme,
            style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w600),
          ),
          SizedBox(height: r.h(12)),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.r(16)),
            ),
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark;
                return SwitchListTile(
                  title: Text(isDark ? l10n.darkMode : l10n.lightMode),
                  value: isDark,
                  onChanged: (value) {
                    context.read<ThemeCubit>().setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: r.h(24)),
          Text(
            'Rain Alerts',
            style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w600),
          ),
          SizedBox(height: r.h(12)),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.r(16)),
            ),
            child: SwitchListTile(
              title: const Text('Background rain monitor'),
              subtitle: const Text(
                'Checks every 5 minutes and alerts if rain is expected in 20 minutes.',
              ),
              value: _rainMonitorEnabled,
              onChanged: _isSavingRainMonitor
                  ? null
                  : (value) => _setRainMonitorEnabled(value),
            ),
          ),
        ],
      ),
    );
  }
}
