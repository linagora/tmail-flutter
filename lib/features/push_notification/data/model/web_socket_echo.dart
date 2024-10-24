import 'package:json_annotation/json_annotation.dart';

part 'web_socket_echo.g.dart';

@JsonSerializable(includeIfNull: false)
class WebSocketEcho {
  @JsonKey(name: '@type')
  final String? type;
  final String? requestId;
  final List<List<dynamic>>? methodResponses;

  WebSocketEcho({
    this.type,
    this.requestId,
    this.methodResponses,
  });

  factory WebSocketEcho.fromJson(Map<String, dynamic> json) => _$WebSocketEchoFromJson(json);

  Map<String, dynamic> toJson() => _$WebSocketEchoToJson(this);

  static bool isValid(Map<String, dynamic> json) {
    try {
      final webSocketEcho = WebSocketEcho.fromJson(json);
      final listResponses = webSocketEcho.methodResponses?.firstOrNull;
      return listResponses?.contains('Core/echo') ?? false;
    } catch (_) {
      return false;
    }
  }
}
