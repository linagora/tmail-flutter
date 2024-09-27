import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/web_socket_action.dart';

part 'connect_web_socket_message.g.dart';

@JsonSerializable()
class ConnectWebSocketMessage with EquatableMixin {
  @JsonKey(name: 'action')
  final WebSocketAction webSocketAction;
  @JsonKey(name: 'url')
  final String webSocketUrl;
  @JsonKey(name: 'ticket')
  final String webSocketTicket;

  ConnectWebSocketMessage({
    required this.webSocketAction,
    required this.webSocketUrl,
    required this.webSocketTicket,
  });

  factory ConnectWebSocketMessage.fromJson(Map<String, dynamic> json) 
    => _$ConnectWebSocketMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectWebSocketMessageToJson(this);
  
  @override
  List<Object?> get props => [webSocketAction, webSocketUrl, webSocketTicket];
}