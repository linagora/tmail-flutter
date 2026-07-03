import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/extensions/set_error_extension.dart';

void main() {
  group('SetErrorLogExtension::logMessage', () {
    test('formats type and description with stable strings', () {
      final setError = SetError(
        SetError.invalidArguments,
        description: 'Blob not an attendee',
      );
      expect(setError.logMessage, '[invalidArguments] Blob not an attendee');
    });

    test('omits null description', () {
      final setError = SetError(SetError.notFound);
      expect(setError.logMessage, '[notFound] ');
    });
  });

  group('MapIdSetErrorLogExtension::toLogMessage', () {
    test('formats each entry as `id: [type] description`', () {
      final mapErrors = {
        Id('blob123'): SetError(
          SetError.forbidden,
          description: 'Not allowed',
        ),
      };
      expect(mapErrors.toLogMessage(), 'blob123: [forbidden] Not allowed');
    });

    test('joins multiple entries with a comma', () {
      final mapErrors = {
        Id('blobA'): SetError(SetError.notFound, description: 'gone'),
        Id('blobB'): SetError(SetError.serverFail, description: 'boom'),
      };
      expect(
        mapErrors.toLogMessage(),
        'blobA: [notFound] gone, blobB: [serverFail] boom',
      );
    });

    test('returns empty string for empty map', () {
      final mapErrors = <Id, SetError>{};
      expect(mapErrors.toLogMessage(), '');
    });

    test('produces no minified runtime type tokens', () {
      final mapErrors = {
        Id('blob123'): SetError(SetError.invalidArguments, description: 'bad'),
      };
      final message = 'Errors: {${mapErrors.toLogMessage()}}';
      expect(message, 'Errors: {blob123: [invalidArguments] bad}');
      expect(message.contains('minified'), isFalse);
      expect(message.contains('Instance of'), isFalse);
    });
  });
}
