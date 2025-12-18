import 'package:json_annotation/json_annotation.dart';

part 'ai_api_response.g.dart';

@JsonSerializable()
class AIApiResponse {
  final List<Choice> choices;

  const AIApiResponse({required this.choices});

  factory AIApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AIApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIApiResponseToJson(this);

  String get content => choices.isNotEmpty ? choices[0].message.content : '';
}

@JsonSerializable()
class Choice {
  final Message message;

  const Choice({required this.message});

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
}

@JsonSerializable()
class Message {
  final String content;

  const Message({required this.content});

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
