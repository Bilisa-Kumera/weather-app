import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  AIService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.openai.com/v1',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: const {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<String> generateWeatherSummary(String weatherData, {Locale? locale}) async {
    final isOromo = locale?.languageCode == 'om';
    
    final instruction = isOromo
        ? 'Ati ogeessa qilleensaa AI dha. Odeeffannoo armaan gadii irratti hundaa\'uun haala qilleensaa sirriitti ibsi.\n\n'
            'Afaan Oromoo qofa fayyadami.\n'
            'Ibsi kee:\n'
            '- Salphaa haa ta\'u\n'
            '- Namaaf hubatamaa haa ta\'u\n'
            '- Gorsa dabaluu (uffata, imala, kkf)\n\n'
            'Odeeffannoo:\n'
        : 'You are an AI weather expert. Based on the information below, provide an accurate weather summary.\n\n'
            'Use English only.\n'
            'Your summary should be:\n'
            '- Concise\n'
            '- Easy to understand\n'
            '- Include advice (clothing, activities, etc.)\n\n'
            'Information:\n';

    return _requestCompletion(
      userPrompt: '$instruction$weatherData',
      maxTokens: 260,
    );
  }

  Future<String> sendChatMessage({
    required String userMessage,
    required String weatherData,
    Locale? locale,
  }) async {
    final isOromo = locale?.languageCode == 'om';
    
    final instruction = isOromo
        ? 'Ati gargaaraa qilleensaa AI dha.\n\n'
            'Gaaffii fayyadamaa deebisi:\n'
            '- Afaan Oromoo qofa fayyadami\n'
            '- Deebii ifaa fi gabaabaa kenni\n'
            '- Yoo danda\'ame gorsa itti dabali\n\n'
            'Gaaffii:\n'
        : 'You are an AI weather assistant.\n\n'
            'Respond to user queries:\n'
            '- Use English only\n'
            '- Provide clear and concise answers\n'
            '- Include advice when possible\n\n'
            'Query:\n';

    final prompt =
        '$instruction$userMessage\n\nCurrent weather information (for reference only):\n$weatherData';

    return _requestCompletion(userPrompt: prompt, maxTokens: 220);
  }

  Future<String> _requestCompletion({
    required String userPrompt,
    int maxTokens = 220,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']?.trim() ?? '';
    final model = dotenv.env['OPENAI_MODEL']?.trim() ?? 'gpt-4o-mini';

    if (apiKey.isEmpty) {
      throw const AIServiceException('OPENAI_API_KEY hin guutamne.');
    }

    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'Ati gargaaraa qilleensaa dha. Afaan Oromoo qofa fayyadami.',
            },
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.6,
          'max_tokens': maxTokens,
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw const AIServiceException('Deebiin AI sirrii miti.');
      }

      final choices = data['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const AIServiceException('AI irraa deebii hin argamne.');
      }

      final first = choices.first;
      if (first is! Map) {
        throw const AIServiceException('Deebiin AI sirrii miti.');
      }

      final message = first['message'];
      if (message is! Map) {
        throw const AIServiceException('Deebiin AI sirrii miti.');
      }

      final content = (message['content'] as String? ?? '').trim();
      if (content.isEmpty) {
        throw const AIServiceException('AI irraa barruun duwwaa dhufe.');
      }

      return content;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final err = _extractErrorMessage(e.response?.data);
      if (status == 401) {
        throw const AIServiceException('OPENAI_API_KEY sirrii miti ykn eeyyama hinqabu.');
      }
      if (err != null && err.isNotEmpty) {
        throw AIServiceException('AI tajaajila irraa dogoggorri dhufe: $err');
      }
      throw const AIServiceException('AI waliin walqunnamtiin hin milkoofne.');
    } catch (_) {
      throw const AIServiceException('AI deebii qopheessuu hin dandeenye.');
    }
  }

  String? _extractErrorMessage(Object? data) {
    if (data is Map && data['error'] is Map) {
      final error = data['error'] as Map;
      final message = error['message'];
      if (message is String) {
        return message;
      }
    }
    return null;
  }
}

class AIServiceException implements Exception {
  const AIServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

