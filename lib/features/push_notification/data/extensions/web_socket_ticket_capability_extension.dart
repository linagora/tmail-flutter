import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:jmap_dart_client/jmap/core/capability/web_socket_ticket_capability.dart';

extension WebSocketTicketCapabilityExtension on WebSocketTicketCapability {
  Uri? get normalizedGenerationEndpoint =>
      generationEndpoint?.normalizePathSlashes();
}
