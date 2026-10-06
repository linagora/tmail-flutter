import 'package:flutter_test/flutter_test.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import '../../../tmail-mcp/marionette/composer/composer_body_driver.dart';
import '../../../tmail-mcp/marionette/marionette_composer_extensions.dart';

void main() {
  test(
    'setBody returns invalid params and skips the driver when text is missing',
    () async {
      final driver = _FakeDriver(const ComposerNotFound());

      final result = await handleSetBody(driver, {});

      expect(result, _isInvalidParams('Missing required parameter: text'));
      expect(driver.setBodyCalls, isEmpty);
    },
  );

  const unavailableComposers = {
    'no composer is open': (ComposerNotFound(), 'No composer editor found'),
    'several composers are open': (
      MultipleComposersFound(),
      'More than one composer is open',
    ),
  };

  for (final MapEntry(key: situation, value: (driverResult, detail))
      in unavailableComposers.entries) {
    test('setBody and getBody return invalid params when $situation', () async {
      final driver = _FakeDriver(driverResult);

      expect(
        await handleSetBody(driver, {'text': 'Hello'}),
        _isInvalidParams(contains(detail)),
      );
      expect(await handleGetBody(driver), _isInvalidParams(contains(detail)));
    });
  }

  test(
    'setBody passes the exact text to the driver and returns the body',
    () async {
      final driver = _FakeDriver(
        const ComposerBodyFound({'body': 'Hi\n\nBye'}),
      );

      final result = await handleSetBody(driver, {'text': 'Hi\n\nBye'});

      expect(driver.setBodyCalls, ['Hi\n\nBye']);
      expect(result, _isSuccess({'body': 'Hi\n\nBye'}));
    },
  );

  test('getBody returns the text and html of the body', () async {
    const body = {'text': 'Hello', 'html': '<div>Hello</div>'};

    final result = await handleGetBody(
      _FakeDriver(const ComposerBodyFound(body)),
    );

    expect(result, _isSuccess(body));
  });
}

Matcher _isInvalidParams(Object detail) =>
    isA<MarionetteExtensionInvalidParams>().having(
      (r) => r.detail,
      'detail',
      detail,
    );

Matcher _isSuccess(Map<String, dynamic> data) =>
    isA<MarionetteExtensionSuccess>().having((r) => r.data, 'data', data);

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
