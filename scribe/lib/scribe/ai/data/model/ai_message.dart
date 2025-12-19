import 'package:json_annotation/json_annotation.dart';

part 'ai_message.g.dart';

@JsonSerializable()
class AIMessage {
  static const String aiUserRole = 'user';

  final String role;
  final String content;

  const AIMessage({
    required this.role,
    required this.content,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AIMessageToJson(this);

  factory AIMessage.ofUser(String content) => AIMessage(
        role: aiUserRole,
        content: content,
      );
}
