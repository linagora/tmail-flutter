import 'package:core/data/network/dio_client.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_request.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_response.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/data/network/ai_api_exception.dart';

class AIApi {
  final DioClient _dioClient;
  final String aiEndpoint;

  AIApi(this._dioClient, this.aiEndpoint);

  Future<AIApiResponse> generateMessage(String prompt) async {
    final aiRequest = _generateRequest(prompt);

    final response = await _dioClient.post(
      aiEndpoint,
      data: aiRequest.toJson(),
      useJMAPHeader: false,
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

  AIAPIRequest _generateRequest(String prompt) {
    return AIAPIRequest(messages: [AIMessage.ofUser(prompt)]);
  }
}
