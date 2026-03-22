import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.dark) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final value = _prefs.getString(AppConstants.prefsThemeMode);
    if (value == 'light') {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(
      AppConstants.prefsThemeMode,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
    emit(mode);
  }
}
