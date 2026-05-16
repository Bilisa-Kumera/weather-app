import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_om.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('om'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WeatherApp'**
  String get appTitle;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get windSpeed;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search City'**
  String get searchCity;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNoInternet;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @afaanOromoo.
  ///
  /// In en, this message translates to:
  /// **'Afaan Oromoo'**
  String get afaanOromoo;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a city name'**
  String get searchHint;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels Like'**
  String get feelsLike;

  /// No description provided for @kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// No description provided for @noCitySelected.
  ///
  /// In en, this message translates to:
  /// **'Please select a city.'**
  String get noCitySelected;

  /// No description provided for @loadingWeather.
  ///
  /// In en, this message translates to:
  /// **'Loading weather data...'**
  String get loadingWeather;

  /// No description provided for @weatherFetchError.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch weather data.'**
  String get weatherFetchError;

  /// No description provided for @noWeatherData.
  ///
  /// In en, this message translates to:
  /// **'No weather data available.'**
  String get noWeatherData;

  /// No description provided for @todayHours.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Hours'**
  String get todayHours;

  /// No description provided for @noHourlyData.
  ///
  /// In en, this message translates to:
  /// **'No hourly data available.'**
  String get noHourlyData;

  /// No description provided for @weeklyForecast.
  ///
  /// In en, this message translates to:
  /// **'Weekly Forecast'**
  String get weeklyForecast;

  /// No description provided for @oromiaCities.
  ///
  /// In en, this message translates to:
  /// **'Oromia Cities'**
  String get oromiaCities;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @pickFromMap.
  ///
  /// In en, this message translates to:
  /// **'Pick from Map'**
  String get pickFromMap;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them to get current location.'**
  String get locationServicesDisabled;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please grant permission.'**
  String get locationPermissionDenied;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @currentLocationError.
  ///
  /// In en, this message translates to:
  /// **'Unable to get current location. Please try again.'**
  String get currentLocationError;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @popularCities.
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get popularCities;

  /// No description provided for @citySelectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Selecting a city enables weather services.'**
  String get citySelectionInfo;

  /// No description provided for @mapPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick Location from Map'**
  String get mapPickerTitle;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @locationServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Service'**
  String get locationServiceTitle;

  /// No description provided for @weatherSummary.
  ///
  /// In en, this message translates to:
  /// **'Weather Summary'**
  String get weatherSummary;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureLabel;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionLabel;

  /// No description provided for @timeDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Time / Day'**
  String get timeDayLabel;

  /// No description provided for @showingHourInfo.
  ///
  /// In en, this message translates to:
  /// **'Currently showing selected hour information.'**
  String get showingHourInfo;

  /// No description provided for @showingDayInfo.
  ///
  /// In en, this message translates to:
  /// **'Currently showing full day information.'**
  String get showingDayInfo;

  /// No description provided for @detailedInfo.
  ///
  /// In en, this message translates to:
  /// **'Detailed Information'**
  String get detailedInfo;

  /// No description provided for @humidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidityLabel;

  /// No description provided for @windLabel.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get windLabel;

  /// No description provided for @feelsLikeLabel.
  ///
  /// In en, this message translates to:
  /// **'Feels Like'**
  String get feelsLikeLabel;

  /// No description provided for @rainChanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Rain Chance'**
  String get rainChanceLabel;

  /// No description provided for @pressureLabel.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressureLabel;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDay;

  /// No description provided for @dayHours.
  ///
  /// In en, this message translates to:
  /// **'Day Hours'**
  String get dayHours;

  /// No description provided for @selectedDays.
  ///
  /// In en, this message translates to:
  /// **'Selected Days'**
  String get selectedDays;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @chatWithAi.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI'**
  String get chatWithAi;

  /// No description provided for @aiPreparing.
  ///
  /// In en, this message translates to:
  /// **'AI is preparing summary...'**
  String get aiPreparing;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chat - {cityName}'**
  String aiChatTitle(Object cityName);

  /// No description provided for @aiChatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask a question...'**
  String get aiChatHint;

  /// No description provided for @aiSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'What\'s the weather like today?'**
  String get aiSuggestion1;

  /// No description provided for @aiSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Is there rain?'**
  String get aiSuggestion2;

  /// No description provided for @aiSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Is it good for travel?'**
  String get aiSuggestion3;

  /// No description provided for @aiSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'When will the rain start?'**
  String get aiSuggestion4;

  /// No description provided for @preparingExperience.
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience...'**
  String get preparingExperience;

  /// No description provided for @loadingYourCity.
  ///
  /// In en, this message translates to:
  /// **'Loading your city...'**
  String get loadingYourCity;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorDetails(Object details);

  /// No description provided for @rainAlerts.
  ///
  /// In en, this message translates to:
  /// **'Rain Alerts'**
  String get rainAlerts;

  /// No description provided for @backgroundRainMonitor.
  ///
  /// In en, this message translates to:
  /// **'Background rain monitor'**
  String get backgroundRainMonitor;

  /// No description provided for @backgroundRainMonitorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checks every 5 minutes and alerts if rain is expected in 20 minutes.'**
  String get backgroundRainMonitorSubtitle;

  /// No description provided for @aiSummaryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'AI summary will appear here shortly.'**
  String get aiSummaryPlaceholder;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions permanently denied. Please enable in settings.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationFoundCoordinatesOnly.
  ///
  /// In en, this message translates to:
  /// **'Location found (coordinates only)'**
  String get locationFoundCoordinatesOnly;

  /// No description provided for @locationFound.
  ///
  /// In en, this message translates to:
  /// **'Location found: {cityName}'**
  String locationFound(Object cityName);

  /// No description provided for @selectCityFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a city first'**
  String get selectCityFirst;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Continue to Home'**
  String get continueToHome;

  /// No description provided for @changeLaterInSettings.
  ///
  /// In en, this message translates to:
  /// **'Note: You can change this later in Settings.'**
  String get changeLaterInSettings;

  /// No description provided for @gettingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingYourLocation;

  /// No description provided for @tapMapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere on the map to select a location'**
  String get tapMapToSelectLocation;

  /// No description provided for @couldNotGetCurrentLocationSelectManually.
  ///
  /// In en, this message translates to:
  /// **'Could not get current location.\\nPlease select location manually on map.'**
  String get couldNotGetCurrentLocationSelectManually;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {details}'**
  String errorGettingLocation(Object details);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Day\\nWith Weather'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast forecasts, clear insights, and smarter decisions.'**
  String get welcomeSubtitle;

  /// No description provided for @featureRealtimeUpdates.
  ///
  /// In en, this message translates to:
  /// **'Real-time updates'**
  String get featureRealtimeUpdates;

  /// No description provided for @featureCitySearch.
  ///
  /// In en, this message translates to:
  /// **'City search'**
  String get featureCitySearch;

  /// No description provided for @feature15DayView.
  ///
  /// In en, this message translates to:
  /// **'15-day view'**
  String get feature15DayView;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'om'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
