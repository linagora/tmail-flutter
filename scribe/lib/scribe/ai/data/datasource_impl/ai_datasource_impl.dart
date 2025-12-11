import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/data/datasource/ai_datasource.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_request.dart';
import 'package:scribe/scribe/ai/data/network/ai_api.dart';
import 'package:scribe/scribe/ai/domain/model/ai_response.dart';

class AIDataSourceImpl implements AIDataSource {
  final AIApi _aiApi;

  AIDataSourceImpl({
    required Dio dio,
    String? endpoint,
  }) : _aiApi = AIApi(
          dio: dio,
          endpoint: endpoint,
        );

  @override
  Future<AIResponse> request(String prompt) async {
    try {
      final aiRequest = AIAPIRequest(
        messages: [
          AIMessage(
            role: 'user',
            content: prompt,
          ),
        ],
      );

      final apiResponse = await _aiApi.chatCompletion(aiRequest);
      return AIResponse(result: apiResponse.content);
    } on DioError catch (e) {
      throw Exception('Failed to generate AI text: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate AI text: $e');
    }
  }
}
