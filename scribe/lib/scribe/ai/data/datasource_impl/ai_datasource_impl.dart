import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/data/datasource/ai_datasource.dart';
import 'package:scribe/scribe/ai/data/network/ai_api.dart';
import 'package:scribe/scribe/ai/domain/model/ai_response.dart';

class AIDataSourceImpl implements AIDataSource {
  final AIApi _aiApi;

  AIDataSourceImpl(this._aiApi);

  @override
  Future<AIResponse> generateMessage(String prompt) async {
    try {
      final apiResponse = await _aiApi.generateMessage(prompt);
      return AIResponse(result: apiResponse.content);
    } on DioException catch (e) {
      throw Exception('Failed to generate AI text: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate AI text: $e');
    }
  }
}
