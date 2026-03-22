import '../repositories/onboarding_repository.dart';

class CompleteOnboarding {
  CompleteOnboarding(this.repository);
  final OnboardingRepository repository;

  Future<void> call() => repository.complete();
}
