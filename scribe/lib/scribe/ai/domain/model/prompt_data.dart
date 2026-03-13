import 'package:scribe/scribe/ai/data/model/ai_message.dart';

class PromptData {
  final List<Prompt> prompts;

  PromptData({
    required this.prompts,
  });

factory PromptData.fromJson(Map<String, dynamic> json) {
    final promptsJson = json['prompts'] as List?;
    
    return PromptData(
      prompts: promptsJson
            ?.whereType<Map<String, dynamic>>()
            .map(Prompt.fromJson) 
            .toList() ??
          const [], 
    );
  }
}

class Prompt {
  final String name;
  final List<AIMessage> messages;

  Prompt({
    required this.name,
    required this.messages,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String) {
      throw const FormatException('Prompt name must be a non-null String');
    }
    
    final messagesJson = json['messages'] as List?;
        
    return Prompt(
      name: name,
      messages: messagesJson
              ?.whereType<Map<String, dynamic>>()
              .map(AIMessage.fromJson)
              .toList() ?? 
          const [],
    );
  }

  List<AIMessage> buildPrompt(String inputText, {String? task}) {
    return [
      for (final message in messages)
        if (message.role == AIRole.system)
          AIMessage.ofSystem(message.content)
        else if (message.role == AIRole.user)
          AIMessage.ofUser(_replacePlaceholders(message.content, inputText, task))
    ];
  }

  String _replacePlaceholders(String content, String inputText, String? task) {
    var result = content.replaceAll('{{input}}', inputText);
    
    if (task != null) {
      result = result.replaceAll('{{task}}', task);
    }
    
    return result;
  }
}