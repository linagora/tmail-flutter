import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_request.dart';

class WebSocketEchoRequest extends WebSocketRequest {
  static const String type = 'Request';
  static const String id = 'R1';
  static final CapabilityIdentifier usingCapability = CapabilityIdentifier.jmapCore;
  static const String method = 'Core/echo';

  @override
  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      'id': id,
      'using': [usingCapability.value.toString()],
      'methodCalls': [[method, {}, 'c0']],
    };
  }
}