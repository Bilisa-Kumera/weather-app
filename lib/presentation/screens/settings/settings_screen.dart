import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/l10n/app_localizations.dart';

import '../../../core/utils/responsive.dart';
import '../../bloc/locale/locale_cubit.dart';
import '../../bloc/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
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
                    context
                        .read<ThemeCubit>()
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
