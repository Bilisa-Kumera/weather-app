part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, loading, success, failure }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.isComplete = false,
    this.message,
  });

  final OnboardingStatus status;
  final bool isComplete;
  final String? message;

  OnboardingState copyWith({
    OnboardingStatus? status,
    bool? isComplete,
    String? message,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      isComplete: isComplete ?? this.isComplete,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, isComplete, message];
}
