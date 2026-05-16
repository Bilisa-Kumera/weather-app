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

  @override
  String get noCitySelected => 'Please select a city.';

  @override
  String get loadingWeather => 'Loading weather data...';

  @override
  String get weatherFetchError => 'Unable to fetch weather data.';

  @override
  String get noWeatherData => 'No weather data available.';

  @override
  String get todayHours => 'Today\'s Hours';

  @override
  String get noHourlyData => 'No hourly data available.';

  @override
  String get weeklyForecast => 'Weekly Forecast';

  @override
  String get oromiaCities => 'Oromia Cities';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get pickFromMap => 'Pick from Map';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please enable them to get current location.';

  @override
  String get enable => 'Enable';

  @override
  String get cancel => 'Cancel';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Please grant permission.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get currentLocationError =>
      'Unable to get current location. Please try again.';

  @override
  String get selectCity => 'Select City';

  @override
  String get popularCities => 'Popular Cities';

  @override
  String get citySelectionInfo => 'Selecting a city enables weather services.';

  @override
  String get mapPickerTitle => 'Pick Location from Map';

  @override
  String get confirm => 'Confirm';

  @override
  String get locationServiceTitle => 'Location Service';

  @override
  String get weatherSummary => 'Weather Summary';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get conditionLabel => 'Condition';

  @override
  String get timeDayLabel => 'Time / Day';

  @override
  String get showingHourInfo => 'Currently showing selected hour information.';

  @override
  String get showingDayInfo => 'Currently showing full day information.';

  @override
  String get detailedInfo => 'Detailed Information';

  @override
  String get humidityLabel => 'Humidity';

  @override
  String get windLabel => 'Wind';

  @override
  String get feelsLikeLabel => 'Feels Like';

  @override
  String get rainChanceLabel => 'Rain Chance';

  @override
  String get pressureLabel => 'Pressure';

  @override
  String get selectDay => 'Select Day';

  @override
  String get dayHours => 'Day Hours';

  @override
  String get selectedDays => 'Selected Days';

  @override
  String get aiSummary => 'AI Summary';

  @override
  String get chatWithAi => 'Chat with AI';

  @override
  String get aiPreparing => 'AI is preparing summary...';

  @override
  String aiChatTitle(Object cityName) {
    return 'AI Chat - $cityName';
  }

  @override
  String get aiChatHint => 'Ask a question...';

  @override
  String get aiSuggestion1 => 'What\'s the weather like today?';

  @override
  String get aiSuggestion2 => 'Is there rain?';

  @override
  String get aiSuggestion3 => 'Is it good for travel?';

  @override
  String get aiSuggestion4 => 'When will the rain start?';

  @override
  String get preparingExperience => 'Preparing your experience...';

  @override
  String get loadingYourCity => 'Loading your city...';

  @override
  String get high => 'High';

  @override
  String get low => 'Low';

  @override
  String get or => 'OR';

  @override
  String errorDetails(Object details) {
    return 'Error: $details';
  }

  @override
  String get rainAlerts => 'Rain Alerts';

  @override
  String get backgroundRainMonitor => 'Background rain monitor';

  @override
  String get backgroundRainMonitorSubtitle =>
      'Checks every 5 minutes and alerts if rain is expected in 20 minutes.';

  @override
  String get aiSummaryPlaceholder => 'AI summary will appear here shortly.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permissions permanently denied. Please enable in settings.';

  @override
  String get locationFoundCoordinatesOnly =>
      'Location found (coordinates only)';

  @override
  String locationFound(Object cityName) {
    return 'Location found: $cityName';
  }

  @override
  String get selectCityFirst => 'Select a city first';

  @override
  String get selected => 'Selected';

  @override
  String get continueToHome => 'Continue to Home';

  @override
  String get changeLaterInSettings =>
      'Note: You can change this later in Settings.';

  @override
  String get gettingYourLocation => 'Getting your location...';

  @override
  String get tapMapToSelectLocation =>
      'Tap anywhere on the map to select a location';

  @override
  String get couldNotGetCurrentLocationSelectManually =>
      'Could not get current location.\\nPlease select location manually on map.';

  @override
  String errorGettingLocation(Object details) {
    return 'Error getting location: $details';
  }

  @override
  String get welcomeTitle => 'Plan Your Day\\nWith Weather';

  @override
  String get welcomeSubtitle =>
      'Fast forecasts, clear insights, and smarter decisions.';

  @override
  String get featureRealtimeUpdates => 'Real-time updates';

  @override
  String get featureCitySearch => 'City search';

  @override
  String get feature15DayView => '15-day view';

  @override
  String get getStarted => 'Get started';
}
