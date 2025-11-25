import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/ai/data/datasource/ai_datasource.dart';
import 'package:tmail_ui_user/features/ai/data/model/ai_message.dart';
import 'package:tmail_ui_user/features/ai/data/model/ai_api_request.dart';
import 'package:tmail_ui_user/features/ai/data/network/ai_api.dart';
import 'package:tmail_ui_user/features/ai/domain/model/ai_response.dart';

class AIDataSourceImpl implements AIDataSource {
  final AIApi _aiApi;
  final String _model = 'gpt-oss-120b';

  AIDataSourceImpl({
    required Dio dio,
  }) : _aiApi = AIApi(
          dio: dio,
          apiKey: 'REDACTED',
          baseUrl: 'https://ai.linagora.com/api/v1',
        );

  @override
  Future<AIResponse> request(String prompt) async {
    try {
      final aiRequest = AIAPIRequest(
        model: _model,
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
