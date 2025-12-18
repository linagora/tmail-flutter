import 'package:core/data/network/dio_client.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_request.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_response.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';

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

    return AIApiResponse.fromJson(response);
  }

  AIAPIRequest _generateRequest(String prompt) {
    return AIAPIRequest(messages: [AIMessage.ofUser(prompt)]);
  }
}
