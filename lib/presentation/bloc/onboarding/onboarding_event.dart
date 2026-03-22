part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOnboarding extends OnboardingEvent {
  const LoadOnboarding();
}

class FinishOnboarding extends OnboardingEvent {
  const FinishOnboarding();
}
