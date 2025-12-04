import 'package:dio/dio.dart';
import '../datasource/ai_datasource.dart';
import '../model/ai_message.dart';
import '../model/ai_api_request.dart';
import '../network/ai_api.dart';
import '../../domain/model/ai_response.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class AIDataSourceImpl implements AIDataSource {
  final AIApi _aiApi;

  AIDataSourceImpl({
    required Dio dio,
  }) : _aiApi = AIApi(
          dio: dio,
          apiKey: AppConfig.aiApiKey,
          baseUrl: AppConfig.aiApiUrl,
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
