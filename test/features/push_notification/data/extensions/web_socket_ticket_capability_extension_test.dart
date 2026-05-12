import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/capability/web_socket_ticket_capability.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/web_socket_ticket_capability_extension.dart';

WebSocketTicketCapability _makeCapability({Uri? gen, Uri? rev}) =>
    WebSocketTicketCapability(generationEndpoint: gen, revocationEndpoint: rev);

void main() {
  group('WebSocketTicketCapabilityExtension', () {
    group('normalizedGenerationEndpoint', () {
      test('should normalize double slashes from server-returned endpoint', () {
        final endpoint = Uri.parse('http://localhost//jmap/ws/ticket');
        expect(
          _makeCapability(gen: endpoint, rev: endpoint)
              .normalizedGenerationEndpoint
              .toString(),
          'http://localhost/jmap/ws/ticket',
        );
      });

      test('should leave endpoint unchanged when path has single slash', () {
        final endpoint = Uri.parse('http://localhost/jmap/ws/ticket');
        expect(
          _makeCapability(gen: endpoint, rev: endpoint)
              .normalizedGenerationEndpoint
              .toString(),
          'http://localhost/jmap/ws/ticket',
        );
      });

      test('should return null when generationEndpoint is null', () {
        expect(_makeCapability().normalizedGenerationEndpoint, isNull);
      });
    });

    group('normalizedRevocationEndpoint', () {
      test('should normalize double slashes from server-returned endpoint', () {
        final endpoint = Uri.parse('http://localhost//jmap/ws/ticket');
        expect(
          _makeCapability(gen: endpoint, rev: endpoint)
              .normalizedRevocationEndpoint
              .toString(),
          'http://localhost/jmap/ws/ticket',
        );
      });

      test('should leave endpoint unchanged when path has single slash', () {
        final endpoint = Uri.parse('http://localhost/jmap/ws/ticket');
        expect(
          _makeCapability(gen: endpoint, rev: endpoint)
              .normalizedRevocationEndpoint
              .toString(),
          'http://localhost/jmap/ws/ticket',
        );
      });

      test('should return null when revocationEndpoint is null', () {
        expect(_makeCapability().normalizedRevocationEndpoint, isNull);
      });

      test('should collapse triple slashes', () {
        final capability = _makeCapability(
          gen: Uri.parse('http://localhost/jmap/ws/ticket'),
          rev: Uri.parse('http://localhost///jmap/ws/ticket'),
        );
        expect(
          capability.normalizedRevocationEndpoint.toString(),
          'http://localhost/jmap/ws/ticket',
        );
      });
    });

    group('independent normalization', () {
      test('should normalize both endpoints independently when they have different slash patterns', () {
        final capability = _makeCapability(
          gen: Uri.parse('http://localhost//gen/ticket'),
          rev: Uri.parse('http://localhost///rev/ticket'),
        );
        expect(capability.normalizedGenerationEndpoint.toString(), 'http://localhost/gen/ticket');
        expect(capability.normalizedRevocationEndpoint.toString(), 'http://localhost/rev/ticket');
      });

      test('should preserve port number in both endpoints', () {
        final capability = _makeCapability(
          gen: Uri.parse('http://localhost:8080//jmap/ws/gen'),
          rev: Uri.parse('http://localhost:8080//jmap/ws/rev'),
        );
        expect(capability.normalizedGenerationEndpoint.toString(), 'http://localhost:8080/jmap/ws/gen');
        expect(capability.normalizedRevocationEndpoint.toString(), 'http://localhost:8080/jmap/ws/rev');
      });
    });
  });
}
