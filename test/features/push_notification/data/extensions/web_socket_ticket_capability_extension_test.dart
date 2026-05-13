import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/capability/web_socket_ticket_capability.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/web_socket_ticket_capability_extension.dart';

WebSocketTicketCapability _makeCapability({Uri? gen}) =>
    WebSocketTicketCapability(generationEndpoint: gen, revocationEndpoint: null);

void main() {
  group('WebSocketTicketCapabilityExtension', () {
    group('normalizedGenerationEndpoint', () {
      test('should normalize double slashes from server-returned endpoint', () {
        final endpoint = Uri.parse('http://localhost//jmap/ws/ticket');
        expect(
          _makeCapability(gen: endpoint).normalizedGenerationEndpoint.toString(),
          'http://localhost/jmap/ws/ticket',
        );
      });

      test('should leave endpoint unchanged when path has single slash', () {
        final endpoint = Uri.parse('http://localhost/jmap/ws/ticket');
        expect(
          _makeCapability(gen: endpoint).normalizedGenerationEndpoint.toString(),
          'http://localhost/jmap/ws/ticket',
        );
      });

      test('should return null when generationEndpoint is null', () {
        expect(_makeCapability().normalizedGenerationEndpoint, isNull);
      });

      test('should preserve port number after normalization', () {
        final endpoint = Uri.parse('http://localhost:8080//jmap/ws/gen');
        expect(
          _makeCapability(gen: endpoint).normalizedGenerationEndpoint.toString(),
          'http://localhost:8080/jmap/ws/gen',
        );
      });
    });
  });
}
