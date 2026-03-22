// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WeatherApp';

  @override
  String get weather => 'Weather';

  @override
  String get temperature => 'Temperature';

  @override
  String get humidity => 'Humidity';

  @override
  String get windSpeed => 'Wind Speed';

  @override
  String get searchCity => 'Search City';

  @override
  String get city => 'City';

  @override
  String get condition => 'Condition';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNoInternet => 'No internet connection.';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get afaanOromoo => 'Afaan Oromoo';

  @override
  String get english => 'English';

  @override
  String get searchHint => 'Enter a city name';

  @override
  String get feelsLike => 'Feels Like';

  @override
  String get kmh => 'km/h';

  @override
  String get percent => '%';
}
