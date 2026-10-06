import 'package:flutter_test/flutter_test.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import '../../../tmail-mcp/marionette/composer/composer_body_driver.dart';
import '../../../tmail-mcp/marionette/marionette_composer_extensions.dart';

void main() {
  group('handleSetBody', () {
    test(
      'returns invalid params and skips the driver when text is missing',
      () async {
        final driver = _FakeDriver(const ComposerNotFound());

        final result = await handleSetBody(driver, {});

        expect(
          result,
          isA<MarionetteExtensionInvalidParams>().having(
            (r) => r.detail,
            'detail',
            'Missing required parameter: text',
          ),
        );
        expect(driver.setBodyCalls, isEmpty);
      },
    );

    test('returns invalid params when no composer is open', () async {
      final driver = _FakeDriver(const ComposerNotFound());

      final result = await handleSetBody(driver, {'text': 'Hello'});

      expect(
        result,
        isA<MarionetteExtensionInvalidParams>().having(
          (r) => r.detail,
          'detail',
          contains('No composer editor found'),
        ),
      );
    });

    test('returns invalid params when several composers are open', () async {
      final result = await handleSetBody(
        _FakeDriver(const MultipleComposersFound()),
        {'text': 'Hello'},
      );

      expect(
        result,
        isA<MarionetteExtensionInvalidParams>().having(
          (r) => r.detail,
          'detail',
          contains('More than one composer is open'),
        ),
      );
    });

    test('passes the exact text to the driver and returns the body', () async {
      final driver = _FakeDriver(
        const ComposerBodyFound({'body': 'Hi\n\nBye'}),
      );

      final result = await handleSetBody(driver, {'text': 'Hi\n\nBye'});

      expect(driver.setBodyCalls, ['Hi\n\nBye']);
      expect(
        result,
        isA<MarionetteExtensionSuccess>().having((r) => r.data, 'data', {
          'body': 'Hi\n\nBye',
        }),
      );
    });
  });

  group('handleGetBody', () {
    test('returns invalid params when no composer is open', () async {
      final result = await handleGetBody(_FakeDriver(const ComposerNotFound()));

      expect(
        result,
        isA<MarionetteExtensionInvalidParams>().having(
          (r) => r.detail,
          'detail',
          contains('No composer editor found'),
        ),
      );
    });

    test('returns invalid params when several composers are open', () async {
      final result = await handleGetBody(
        _FakeDriver(const MultipleComposersFound()),
      );

      expect(
        result,
        isA<MarionetteExtensionInvalidParams>().having(
          (r) => r.detail,
          'detail',
          contains('More than one composer is open'),
        ),
      );
    });

    test('returns the text and html of the body', () async {
      const body = {'text': 'Hello', 'html': '<div>Hello</div>'};

      final result = await handleGetBody(
        _FakeDriver(const ComposerBodyFound(body)),
      );

      expect(
        result,
        isA<MarionetteExtensionSuccess>().having((r) => r.data, 'data', body),
      );
    });
  });
}

class _FakeDriver implements ComposerBodyDriver {
  _FakeDriver(this._result);

  final ComposerBodyResult _result;
  final setBodyCalls = <String>[];

  @override
  Future<ComposerBodyResult> setBody(String text) async {
    setBodyCalls.add(text);
    return _result;
  }

  @override
  Future<ComposerBodyResult> getBody() async => _result;
}
