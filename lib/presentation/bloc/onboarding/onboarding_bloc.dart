import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/usecases/check_onboarding.dart';
import '../../../domain/usecases/complete_onboarding.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required CheckOnboarding checkOnboarding,
    required CompleteOnboarding completeOnboarding,
  })  : _checkOnboarding = checkOnboarding,
        _completeOnboarding = completeOnboarding,
        super(const OnboardingState()) {
    on<LoadOnboarding>(_onLoadOnboarding);
    on<FinishOnboarding>(_onFinishOnboarding);
  }

  final CheckOnboarding _checkOnboarding;
  final CompleteOnboarding _completeOnboarding;

  Future<void> _onLoadOnboarding(
    LoadOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final complete = await _checkOnboarding();
      emit(state.copyWith(
        status: OnboardingStatus.success,
        isComplete: complete,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        isComplete: false,
        message: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        isComplete: false,
        message: 'Failed to load onboarding state',
      ));
    }
  }

  Future<void> _onFinishOnboarding(
    FinishOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      await _completeOnboarding();
      emit(state.copyWith(status: OnboardingStatus.success, isComplete: true));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        message: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        message: 'Failed to save onboarding state',
      ));
    }
  }
}
