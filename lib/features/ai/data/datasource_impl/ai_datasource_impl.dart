import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/ai/data/datasource/ai_datasource.dart';
import 'package:tmail_ui_user/features/ai/domain/model/ai_response.dart';

class AIDataSourceImpl implements AIDataSource {
  final Dio _dio;
  final String _apiKey = 'REDACTED';
  final String _baseUrl = 'https://ai.linagora.com/api/v1';
  final String _model = 'gpt-oss-120b';

  AIDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;
  @override
  Future<AIResponse> request(String prompt) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.3,
          'top_p': 1,
          'stream': false,
          'logprobs': 0,
        },
      );

      if (response.statusCode == 200) {
        final aiResponseContent = response.data['choices']?[0]?['message']?['content'];
        if (aiResponseContent != null && aiResponseContent.isNotEmpty) {
          return AIResponse(result: aiResponseContent.toString());
        } else {
          throw Exception('Empty response from AI service');
        }
      } else {
        throw Exception('AI API returned status code: ${response.statusCode}');
      }
    } on DioError catch (e) {
      throw Exception('Failed to generate AI text: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate AI text: $e');
    }
  }
}
