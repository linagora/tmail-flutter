import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class WebSocketEchoRequest {
  static const String type = 'Request';
  static const String id = 'R1';
  static CapabilityIdentifier using = CapabilityIdentifier.jmapCore;
  static const String method = 'Core/echo';

  const WebSocketEchoRequest._();

  static Map<String, dynamic> toJson() {
    return {
      '@type': type,
      'id': id,
      'using': [using.value.toString()],
      'methodCalls': [[method, {}, 'c0']],
    };
  }
}