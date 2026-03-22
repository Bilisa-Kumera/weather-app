import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../constants/app_constants.dart';

class ApiClient {
  ApiClient() : _dio = Dio(_baseOptions()) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  final Dio _dio;

  Dio get dio => _dio;

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: AppConstants.weatherApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
      queryParameters: {
        'key': Env.weatherApiKey,
      },
    );
  }
}
