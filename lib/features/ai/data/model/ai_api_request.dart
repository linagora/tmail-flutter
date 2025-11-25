import 'package:tmail_ui_user/features/ai/data/model/ai_message.dart';

class AIAPIRequest {
  final String model;
  final List<AIMessage> messages;
  final double temperature;
  final int topP;
  final bool stream;
  final int logprobs;

  const AIAPIRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.3,
    this.topP = 1,
    this.stream = false,
    this.logprobs = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': temperature,
      'top_p': topP,
      'stream': stream,
      'logprobs': logprobs,
    };
  }
}
