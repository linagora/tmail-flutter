import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_response.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_request.dart';
import 'package:scribe/scribe/ai/data/network/ai_api_exception.dart';

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
      throw AIApiNotAvailableException();
    }

    final response = await _dio.post(
      url,
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      if (response.data == null || response.data.isEmpty) {
        throw AIApiEmptyResponseException();
      }
      return AIApiResponse.fromJson(response.data);
    } else {
      throw AIApiException(
        'AI API returned status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
