import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_response.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_request.dart';

class AIApi {
  final Dio _dio;
  final String? _endpoint;

  AIApi({
    required Dio dio,
    String? endpoint,
  }) : _dio = dio,
       _endpoint = endpoint;

  Future<AIApiResponse> chatCompletion(
    AIAPIRequest request
    ) async {
    final url = _endpoint;

    if (url == null) {
      throw Exception('AI API is not available');
    }

    final response = await _dio.post(
      url,
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      if (response.data == null || response.data.isEmpty) {
        throw Exception('AI API returned empty response');
      }
      return AIApiResponse.fromJson(response.data);
    } else {
      throw Exception('AI API returned status code: ${response.statusCode}');
    }
  }
}
