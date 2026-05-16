import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/ai_service.dart';

class AIChatMessage extends Equatable {
  const AIChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;

  @override
  List<Object?> get props => [text, isUser, timestamp];
}

abstract class AIEvent extends Equatable {
  const AIEvent();

  @override
  List<Object?> get props => [];
}

class GenerateWeatherSummary extends AIEvent {
  const GenerateWeatherSummary({required this.weatherData});

  final String weatherData;

  @override
  List<Object?> get props => [weatherData];
}

class SendChatMessage extends AIEvent {
  const SendChatMessage({
    required this.userMessage,
    required this.weatherData,
  });

  final String userMessage;
  final String weatherData;

  @override
  List<Object?> get props => [userMessage, weatherData];
}

abstract class AIState extends Equatable {
  const AIState();

  @override
  List<Object?> get props => [];
}

class AIInitial extends AIState {
  const AIInitial();
}

class AILoading extends AIState {
  const AILoading({
    this.previousSummary,
    this.chatMessages = const [],
    this.fromChat = false,
  });

  final String? previousSummary;
  final List<AIChatMessage> chatMessages;
  final bool fromChat;

  @override
  List<Object?> get props => [previousSummary, chatMessages, fromChat];
}

class AISuccess extends AIState {
  const AISuccess(this.summary);

  final String summary;

  @override
  List<Object?> get props => [summary];
}

class AIChatLoaded extends AIState {
  const AIChatLoaded(this.messages);

  final List<AIChatMessage> messages;

  @override
  List<Object?> get props => [messages];
}

class AIError extends AIState {
  const AIError({
    required this.message,
    this.chatMessages = const [],
    this.previousSummary,
  });

  final String message;
  final List<AIChatMessage> chatMessages;
  final String? previousSummary;

  @override
  List<Object?> get props => [message, chatMessages, previousSummary];
}

class AIBloc extends Bloc<AIEvent, AIState> {
  AIBloc({
    required AIService aiService,
    required Locale locale,
  })
      : _aiService = aiService,
        _locale = locale,
        super(const AIInitial()) {
    on<GenerateWeatherSummary>(_onGenerateWeatherSummary);
    on<SendChatMessage>(_onSendChatMessage);
  }

  final AIService _aiService;
  final Locale _locale;
  final List<AIChatMessage> _chatMessages = [];
  String? _latestSummary;

  Future<void> _onGenerateWeatherSummary(
    GenerateWeatherSummary event,
    Emitter<AIState> emit,
  ) async {
    emit(
      AILoading(
        previousSummary: _latestSummary,
        chatMessages: List<AIChatMessage>.unmodifiable(_chatMessages),
      ),
    );

    try {
      final summary = await _aiService.generateWeatherSummary(event.weatherData, locale: _locale);
      _latestSummary = summary;
      emit(AISuccess(summary));
    } catch (e) {
      emit(
        AIError(
          message: e.toString().replaceFirst('Exception: ', ''),
          chatMessages: List<AIChatMessage>.unmodifiable(_chatMessages),
          previousSummary: _latestSummary,
        ),
      );
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<AIState> emit,
  ) async {
    final text = event.userMessage.trim();
    if (text.isEmpty) {
      return;
    }

    _chatMessages.add(
      AIChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );

    emit(
      AILoading(
        previousSummary: _latestSummary,
        chatMessages: List<AIChatMessage>.unmodifiable(_chatMessages),
        fromChat: true,
      ),
    );

    try {
      final aiReply = await _aiService.sendChatMessage(
        userMessage: text,
        weatherData: event.weatherData,
        locale: _locale,
      );

      _chatMessages.add(
        AIChatMessage(text: aiReply, isUser: false, timestamp: DateTime.now()),
      );

      emit(AIChatLoaded(List<AIChatMessage>.unmodifiable(_chatMessages)));
    } catch (e) {
      emit(
        AIError(
          message: e.toString().replaceFirst('Exception: ', ''),
          chatMessages: List<AIChatMessage>.unmodifiable(_chatMessages),
          previousSummary: _latestSummary,
        ),
      );
      emit(AIChatLoaded(List<AIChatMessage>.unmodifiable(_chatMessages)));
    }
  }
}

