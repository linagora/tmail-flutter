import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/domain/model/ai_response.dart';

abstract class AIDataSource {
  Future<AIResponse> generateMessage(List<AIMessage> messages);
}
