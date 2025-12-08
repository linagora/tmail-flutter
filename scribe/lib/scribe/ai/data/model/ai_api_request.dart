import 'package:scribe/scribe/ai/data/model/ai_message.dart';

class AIAPIRequest {
  static const String _defaultModel = 'gpt-oss-120b';

  final List<AIMessage> messages;

  const AIAPIRequest({
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': _defaultModel,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
