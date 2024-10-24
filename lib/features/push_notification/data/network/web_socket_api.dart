
import 'package:core/data/network/dio_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/web_socket_ticket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_ticket.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class WebSocketApi {
  final DioClient _dioClient;

  WebSocketApi(this._dioClient);

  Future<String> getWebSocketTicket(
    Session session,
    AccountId accountId
  ) async {
    requireCapability(
      session,
      accountId,
      [CapabilityIdentifier.jmapWebSocketTicket]);
    final webSocketTicketCapability = session.getCapabilityProperties<WebSocketTicketCapability>(
      accountId,
      CapabilityIdentifier.jmapWebSocketTicket);
    
    final webSocketTicketGenerationUrl = webSocketTicketCapability?.generationEndpoint;
    if (webSocketTicketGenerationUrl == null) {
      throw WebSocketTicketUnavailableException();
    }
    final webSocketTicketGenerationResponse = await _dioClient.post(
      '$webSocketTicketGenerationUrl');
    final webSocketTicket = WebSocketTicket.fromJson(
      webSocketTicketGenerationResponse);
    if (webSocketTicket.value == null) {
      throw WebSocketTicketUnavailableException();
    }

    return webSocketTicket.value!;
  }
}