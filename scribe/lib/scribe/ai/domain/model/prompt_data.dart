import 'package:scribe/scribe/ai/data/model/ai_message.dart';

class PromptData {
  final List<Prompt> prompts;

  PromptData({
    required this.prompts,
  });

  factory PromptData.fromJson(Map<String, dynamic> json) {
    final promptsJson = json['prompts'];
    if (promptsJson is! List<dynamic>) {
      return PromptData(prompts: []);
    }
    
    return PromptData(
      prompts: promptsJson
          .whereType<Map<String, dynamic>>()
          .map((promptJson) => Prompt.fromJson(promptJson))
          .toList(),
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
    
    final messagesJson = json['messages'];
    if (messagesJson is! List<dynamic>) {
      return Prompt(name: name, messages: []);
    }
    
    return Prompt(
      name: name,
      messages: messagesJson
          .whereType<Map<String, dynamic>>()
          .map((messageJson) => AIMessage.fromJson(messageJson))
          .toList(),
    );
  }

  List<AIMessage> buildPrompt(String inputText, {String? task}) {
    final messages = <AIMessage>[];
    for (final message in this.messages) {
      if (message.role == AIRole.system) {
        messages.add(AIMessage.ofSystem(message.content));
      } else if (message.role == AIRole.user) {
        final userContent = _replacePlaceholders(message.content, inputText, task);
        messages.add(AIMessage.ofUser(userContent));
      }
    }
    return messages;
  }

  String _replacePlaceholders(String content, String inputText, String? task) {
    String result = content;
    if (result.contains('{{input}}')) {
      result = result.replaceAll('{{input}}', inputText);
    }
    if (task != null && result.contains('{{task}}')) {
      result = result.replaceAll('{{task}}', task);
    }
    return result;
  }
}