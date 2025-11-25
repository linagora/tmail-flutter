class AIApiResponse {
  final String content;

  const AIApiResponse({required this.content});

  static AIApiResponse? parse(Map<String, dynamic> json) {
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return null;
    }

    final firstChoice = choices[0] as Map<String, dynamic>?;
    if (firstChoice == null) {
      return null;
    }

    final message = firstChoice['message'] as Map<String, dynamic>?;
    if (message == null) {
      return null;
    }

    final content = message['content'] as String?;
    if (content == null || content.isEmpty) {
      return null;
    }

    return AIApiResponse(content: content);
  }
}
