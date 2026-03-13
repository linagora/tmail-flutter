import 'package:core/data/network/dio_client.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_request.dart';
import 'package:scribe/scribe/ai/data/model/ai_api_response.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';

class AIApi {
  final DioClient _dioClient;
  final String aiEndpoint;

  AIApi(this._dioClient, this.aiEndpoint);

  Future<AIApiResponse> generateMessage(List<AIMessage> messages) async {
    final aiRequest = AIAPIRequest(messages: messages);

    final response = await _dioClient.post(
      aiEndpoint,
      data: aiRequest.toJson(),
      useJMAPHeader: false,
    );

    return AIApiResponse.fromJson(response);
  }
}
