import 'package:json_annotation/json_annotation.dart';

part 'ai_message.g.dart';

enum AIRole {
  @JsonValue('user')
  user,
  @JsonValue('system')
  system,
}

@JsonSerializable()
class AIMessage {
  final AIRole role;
  final String content;

  const AIMessage({
    required this.role,
    required this.content,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AIMessageToJson(this);

  factory AIMessage.ofUser(String content) => AIMessage(
        role: AIRole.user,
        content: content,
      );

  factory AIMessage.ofSystem(String content) => AIMessage(
        role: AIRole.system,
        content: content,
      );
}
