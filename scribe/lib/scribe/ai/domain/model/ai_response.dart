class AIResponse {
  final String result;

  const AIResponse({required this.result});

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      result: json['result'] as String? ?? json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
    };
  }
}
