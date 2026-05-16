// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get appTitle => 'WeatherApp';

  @override
  String get weather => 'Haala Qilleensaa';

  @override
  String get temperature => 'Ho\'ina';

  @override
  String get humidity => 'Jiidhina';

  @override
  String get windSpeed => 'Saffisa Bubbee';

  @override
  String get searchCity => 'Magaalaa barbaadi';

  @override
  String get city => 'Magaalaa';

  @override
  String get condition => 'Haala';

  @override
  String get lastUpdated => 'Yeroo Dhumaa Haaromfame';

  @override
  String get loading => 'Fe\'amaa jira...';

  @override
  String get errorGeneric => 'Dogoggorri uumame. Irra deebi\'ii.';

  @override
  String get errorNoInternet => 'Walitti dhufeenyi intarneetii hin jiru.';

  @override
  String get retry => 'Irra deebi\'ii';

  @override
  String get settings => 'Qindaa\'ina';

  @override
  String get language => 'Afaan';

  @override
  String get theme => 'Bifa';

  @override
  String get darkMode => 'Bifa Gurraacha';

  @override
  String get lightMode => 'Bifa Ifa';

  @override
  String get afaanOromoo => 'Afaan Oromoo';

  @override
  String get english => 'Ingiliffa';

  @override
  String get searchHint => 'Maqaa magaalaa galchi';

  @override
  String get feelsLike => 'Akka Namaatti Dhaga\'amu';

  @override
  String get kmh => 'km/h';

  @override
  String get percent => '%';

  @override
  String get noCitySelected => 'Itti fufuuf magaalaa filadhu.';

  @override
  String get loadingWeather => 'Tilmaama haaraa fe\'aa jira...';

  @override
  String get weatherFetchError => 'Haala qilleensaa fe\'uu hin dandeenye.';

  @override
  String get noWeatherData => 'Daataan haala qilleensaa amma hin jiru.';

  @override
  String get todayHours => 'Sa\'aatii har\'a';

  @override
  String get noHourlyData => 'Daataan sa\'aatii har\'aa amma hin jiru.';

  @override
  String get weeklyForecast => 'Tilmaama Torban';

  @override
  String get oromiaCities => 'Magaalota Oromiyaa';

  @override
  String get currentLocation => 'Bakka Ammaa';

  @override
  String get pickFromMap => 'Kaartaa Itta';

  @override
  String get selectLocation => 'Bakka Fili';

  @override
  String get locationServicesDisabled =>
      'Tajaajila bakka irraa qabuu cufameera. Bakka ammaa argachuuf tajaajila bakka banneessuu qabda.';

  @override
  String get enable => 'Banneessi';

  @override
  String get cancel => 'Haqi';

  @override
  String get locationPermissionDenied =>
      'Hayyama bakka irraa qabuu hin kennine. Maaloo kennee.';

  @override
  String get grantPermission => 'Hayyama Kenne';

  @override
  String get currentLocationError =>
      'Bakka ammaa arguu hin dandeenye. Maaloo irra deebi\'aa.';

  @override
  String get selectCity => 'Magaalaa Filadhu';

  @override
  String get popularCities => 'Magaaloota Beekamoo';

  @override
  String get citySelectionInfo => 'Magaalaa filachuun tajaajila bira gahuuf.';

  @override
  String get mapPickerTitle => 'Kaartaa Itta Bakka Fili';

  @override
  String get confirm => 'Fili';

  @override
  String get locationServiceTitle => 'Tajaajila Bakka';

  @override
  String get weatherSummary => 'Gabaabina Qilleensaa';

  @override
  String get temperatureLabel => 'Ho\'a';

  @override
  String get conditionLabel => 'Haala Qilleensaa';

  @override
  String get timeDayLabel => 'Yeroo / Guyyaa';

  @override
  String get showingHourInfo => 'Amma odeeffannoo sa\'aatii filatame agarta.';

  @override
  String get showingDayInfo => 'Amma odeeffannoo guyyaa guutuu agarta.';

  @override
  String get detailedInfo => 'Bal\'ina Odeeffannoo';

  @override
  String get humidityLabel => 'Hamma Bishaan Qilleensaa';

  @override
  String get windLabel => 'Bubbee';

  @override
  String get feelsLikeLabel => 'Akka itti dhagahamu';

  @override
  String get rainChanceLabel => 'Carraa Roobaa';

  @override
  String get pressureLabel => 'Dhiibbaa Qilleensaa';

  @override
  String get selectDay => 'Guyyaa Filadhu';

  @override
  String get dayHours => 'Sa\'aatii Guyyaa';

  @override
  String get selectedDays => 'Guyyoota Filannoo';

  @override
  String get aiSummary => 'Ibsa AI';

  @override
  String get chatWithAi => 'AI waliin haasayi';

  @override
  String get aiPreparing => 'AI ibsa qopheessaa jira...';

  @override
  String aiChatTitle(Object cityName) {
    return 'AI Waliin Haasawa - $cityName';
  }

  @override
  String get aiChatHint => 'Gaaffii kee barreessi...';

  @override
  String get aiSuggestion1 => 'Har\'a maal uffadhu?';

  @override
  String get aiSuggestion2 => 'Roobni ni jiraa?';

  @override
  String get aiSuggestion3 => 'Imalaaf gaariidhaa?';

  @override
  String get aiSuggestion4 => 'Roobni yoom jalqaba?';

  @override
  String get preparingExperience => 'Muuxannoo kee qopheessaa jira...';

  @override
  String get loadingYourCity => 'Magaalaa kee fe\'aa jira...';

  @override
  String get high => 'Ol';

  @override
  String get low => 'Gadi';

  @override
  String get or => 'Ykn';

  @override
  String errorDetails(Object details) {
    return 'Dogoggora: $details';
  }

  @override
  String get rainAlerts => 'Hubachiisa Roobaa';

  @override
  String get backgroundRainMonitor => 'Rooba hordofuu duubbee';

  @override
  String get backgroundRainMonitorSubtitle =>
      'Daqiiqaa 5 keessatti sakatta\'a; yoo daqiiqaa 20 keessatti roobni eegamu beeksisa.';

  @override
  String get aiSummaryPlaceholder =>
      'AI irraa ibsa argachuuf yeroo gabaabaa eegaa.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Hayyamni bakka yeroo hundaaf dhorkameera. Maaloo Qindaa\'ina keessatti banuu qabda.';

  @override
  String get locationFoundCoordinatesOnly =>
      'Bakka argame (koo\'ordinaata qofa)';

  @override
  String locationFound(Object cityName) {
    return 'Bakka argame: $cityName';
  }

  @override
  String get selectCityFirst => 'Jalqaba magaalaa filadhu';

  @override
  String get selected => 'Filatame';

  @override
  String get continueToHome => 'Gara Fuula Ijoo Itti Fufi';

  @override
  String get changeLaterInSettings =>
      'Hubachiisa: Booda keessaa Qindaa\'ina irraa jijjiiruu dandeessa.';

  @override
  String get gettingYourLocation => 'Bakka kee barbaadaa jira...';

  @override
  String get tapMapToSelectLocation =>
      'Kaartaa irratti bakka filachuuf bakka barbaadde tuqi';

  @override
  String get couldNotGetCurrentLocationSelectManually =>
      'Bakka ammaa arguu hin dandeenye.\\nMaaloo kaartaa irratti harkaan filadhu.';

  @override
  String errorGettingLocation(Object details) {
    return 'Dogoggora bakka argachuun: $details';
  }

  @override
  String get welcomeTitle => 'Guyyaa Kee\\nHaala Qilleensaan Karoorfadhu';

  @override
  String get welcomeSubtitle =>
      'Tilmaama saffisaa, odeeffannoo ifaa fi fuula murtii saffisaa.';

  @override
  String get featureRealtimeUpdates => 'Haaromsa yeroo';

  @override
  String get featureCitySearch => 'Barbaacha magaalaa';

  @override
  String get feature15DayView => 'Mul\'ata guyyaa 15';

  @override
  String get getStarted => 'Jalqabi';
}
