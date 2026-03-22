import '../repositories/onboarding_repository.dart';

class CheckOnboarding {
  CheckOnboarding(this.repository);
  final OnboardingRepository repository;

  Future<bool> call() => repository.isComplete();
}
