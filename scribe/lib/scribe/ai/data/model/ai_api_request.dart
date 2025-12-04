import 'ai_message.dart';

class AIAPIRequest {
  final List<AIMessage> messages;

  const AIAPIRequest({
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': 'gpt-oss-120b',
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
