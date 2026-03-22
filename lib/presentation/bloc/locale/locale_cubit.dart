import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(AppConstants.defaultLocale) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final code = _prefs.getString(AppConstants.prefsLocaleCode);
    final locale =
        (code != null && code.isNotEmpty) ? Locale(code) : AppConstants.defaultLocale;
    final supported = _ensureSupported(locale);
    if (code == null || supported.languageCode != code) {
      _prefs.setString(AppConstants.prefsLocaleCode, supported.languageCode);
    }
    emit(supported);
  }

  Locale _ensureSupported(Locale locale) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return AppConstants.defaultLocale;
  }

  Future<void> setLocale(Locale locale) async {
    final supported = _ensureSupported(locale);
    await _prefs.setString(
      AppConstants.prefsLocaleCode,
      supported.languageCode,
    );
    emit(supported);
  }
}
