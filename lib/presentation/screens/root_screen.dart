import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/l10n/app_localizations.dart';

import '../bloc/city/city_bloc.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../widgets/state/error_state_view.dart';
import '../widgets/state/loading_state_view.dart';
import 'home/home_screen.dart';
import 'onboarding/onboarding_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, onboardingState) {
        if (onboardingState.status == OnboardingStatus.loading) {
          return LoadingStateView(message: l10n.preparingExperience);
        }
        if (onboardingState.status == OnboardingStatus.failure) {
          return ErrorStateView(
            message: l10n.errorGeneric,
            onRetry: () => context.read<OnboardingBloc>().add(const LoadOnboarding()),
          );
        }

        return BlocBuilder<CityBloc, CityState>(
          builder: (context, cityState) {
            final isInitialCityLoad = onboardingState.isComplete &&
                cityState.status == CityStatus.loading &&
                cityState.selectedCity == null;
            if (isInitialCityLoad) {
              return LoadingStateView(message: l10n.loadingYourCity);
            }

            final needsOnboarding =
                !onboardingState.isComplete || cityState.selectedCity == null;
            if (needsOnboarding) {
              return const OnboardingScreen();
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
