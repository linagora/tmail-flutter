import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_response.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_request.dart';

class AIApi {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  AIApi({
    required Dio dio,
    required String apiKey,
    required String baseUrl,
  })  : _dio = dio,
        _apiKey = apiKey,
        _baseUrl = baseUrl;

  Future<AIApiResponse> chatCompletion(AIAPIRequest request) async {
    final response = await _dio.post(
      '$_baseUrl/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      return AIApiResponse.fromJson(response.data);
    } else {
      throw Exception('AI API returned status code: ${response.statusCode}');
    }
  }
}
