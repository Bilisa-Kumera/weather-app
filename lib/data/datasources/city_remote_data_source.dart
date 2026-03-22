import 'package:dio/dio.dart';

import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/city_model.dart';

class CityRemoteDataSource {
  CityRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<CityModel>> searchCities(String query) async {
    try {
      final response = await _client.dio.get(
        '/search.json',
        queryParameters: {'q': query},
      );
      final data = (response.data as List<dynamic>).cast<Map<String, dynamic>>();
      return data.map(CityModel.fromJson).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'City search failed');
    }
  }
}
