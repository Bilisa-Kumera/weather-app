import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/l10n/app_localizations.dart';
import 'package:weatherapp/l10n/fallback_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/city_local_data_source.dart';
import 'data/datasources/city_remote_data_source.dart';
import 'data/datasources/weather_local_data_source.dart';
import 'data/datasources/weather_remote_data_source.dart';
import 'data/repositories/city_repository_impl.dart';
import 'data/repositories/onboarding_repository_impl.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/usecases/check_onboarding.dart';
import 'domain/usecases/complete_onboarding.dart';
import 'domain/usecases/get_current_weather.dart';
import 'domain/usecases/get_forecast.dart';
import 'domain/usecases/get_history.dart';
import 'domain/usecases/get_saved_city.dart';
import 'domain/usecases/save_city.dart';
import 'domain/usecases/search_cities.dart';
import 'presentation/bloc/city/city_bloc.dart';
import 'presentation/bloc/locale/locale_cubit.dart';
import 'presentation/bloc/onboarding/onboarding_bloc.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/bloc/weather/weather_bloc.dart';
import 'presentation/screens/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(() {
    debugPaintBaselinesEnabled = false;
    return true;
  }());
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();

  final settingsBox = await Hive.openBox(AppConstants.boxSettings);
  final cacheBox = await Hive.openBox(AppConstants.boxCache);

  final prefs = await SharedPreferences.getInstance();

  final apiClient = ApiClient();
  final weatherRemote = WeatherRemoteDataSource(apiClient);
  final weatherLocal = WeatherLocalDataSource(cacheBox);
  final cityRemote = CityRemoteDataSource(apiClient);
  final cityLocal = CityLocalDataSource(settingsBox);

  final weatherRepository = WeatherRepositoryImpl(weatherRemote, weatherLocal);
  final cityRepository = CityRepositoryImpl(cityRemote, cityLocal);
  final onboardingRepository = OnboardingRepositoryImpl(cityLocal);

  runApp(
    WeatherApp(
      prefs: prefs,
      weatherRepository: weatherRepository,
      cityRepository: cityRepository,
      onboardingRepository: onboardingRepository,
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({
    super.key,
    required this.prefs,
    required this.weatherRepository,
    required this.cityRepository,
    required this.onboardingRepository,
  });

  final SharedPreferences prefs;
  final WeatherRepositoryImpl weatherRepository;
  final CityRepositoryImpl cityRepository;
  final OnboardingRepositoryImpl onboardingRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: weatherRepository),
        RepositoryProvider.value(value: cityRepository),
        RepositoryProvider.value(value: onboardingRepository),
        RepositoryProvider(create: (_) => GetCurrentWeather(weatherRepository)),
        RepositoryProvider(create: (_) => GetForecast(weatherRepository)),
        RepositoryProvider(create: (_) => GetHistory(weatherRepository)),
        RepositoryProvider(create: (_) => GetSavedCity(cityRepository)),
        RepositoryProvider(create: (_) => SaveCity(cityRepository)),
        RepositoryProvider(create: (_) => SearchCities(cityRepository)),
        RepositoryProvider(create: (_) => CheckOnboarding(onboardingRepository)),
        RepositoryProvider(create: (_) => CompleteOnboarding(onboardingRepository)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocaleCubit(prefs)),
          BlocProvider(create: (_) => ThemeCubit(prefs)),
          BlocProvider(
            create: (context) => CityBloc(
              getSavedCity: context.read<GetSavedCity>(),
              saveCity: context.read<SaveCity>(),
            )..add(const LoadSavedCity()),
          ),
          BlocProvider(
            create: (context) => OnboardingBloc(
              checkOnboarding: context.read<CheckOnboarding>(),
              completeOnboarding: context.read<CompleteOnboarding>(),
            )..add(const LoadOnboarding()),
          ),
          BlocProvider(
            create: (context) => WeatherBloc(
              getCurrentWeather: context.read<GetCurrentWeather>(),
              getForecast: context.read<GetForecast>(),
              getHistory: context.read<GetHistory>(),
            ),
          ),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: [
                    FallbackMaterialLocalizationsDelegate.delegate,
                    FallbackCupertinoLocalizationsDelegate.delegate,
                    ...AppLocalizations.localizationsDelegates,
                  ],
                  home: const RootScreen(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
