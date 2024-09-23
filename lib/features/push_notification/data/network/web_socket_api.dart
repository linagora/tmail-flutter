import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_ticket.dart';

class WebSocketApi {
  final DioClient _dioClient;

  WebSocketApi(this._dioClient);

  Future<WebSocketTicket> getWebSocketTicket(String url) async {
    final response = await _dioClient.post(url);
    return WebSocketTicket.fromJson(jsonDecode(response.data));
  }
}