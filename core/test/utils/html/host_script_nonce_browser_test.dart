@TestOn('chrome')

import 'package:core/utils/html/host_script_nonce.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('reads a valid nonce and rejects an empty or invalid one', () {
    final valid = _insertNonceScript('aBc123+/=_-XYZ');
    expect(valid.getAttribute('nonce'), '');
    expect(valid.nonce, 'aBc123+/=_-XYZ');
    expect(HostScriptNonce.read(), 'aBc123+/=_-XYZ');
    valid.remove();

    final empty = _insertNonceScript('');
    expect(HostScriptNonce.read(), isNull);
    empty.remove();

    final invalid = _insertNonceScript('bad nonce');
    expect(HostScriptNonce.read(), isNull);
    invalid.remove();

    expect(HostScriptNonce.read(), isNull);
  });

  test('uses the first valid host nonce when an earlier one is invalid', () {
    final invalid = _appendNonceScript('bad nonce');
    final valid = _appendNonceScript('widgetTestNonce1');
    expect(HostScriptNonce.read(), 'widgetTestNonce1');
    valid.remove();
    invalid.remove();
  });

  test('reads a host nonce set only on the script property', () {
    final script = web.HTMLScriptElement()..nonce = 'propertyOnlyNonce1';
    script.removeAttribute('nonce');
    web.document.head!.append(script);
    expect(script.hasAttribute('nonce'), isFalse);
    expect(script.nonce, 'propertyOnlyNonce1');
    expect(HostScriptNonce.read(), 'propertyOnlyNonce1');
    script.remove();
  });
}

web.HTMLScriptElement _nonceScript(String nonce) {
  // Attribute stays blank; only the .nonce property holds the value.
  return web.HTMLScriptElement()
    ..setAttribute('nonce', '')
    ..nonce = nonce;
}

web.HTMLScriptElement _insertNonceScript(String nonce) {
  final script = _nonceScript(nonce);
  web.document.head!.insertBefore(script, web.document.head!.firstChild);
  return script;
}

web.HTMLScriptElement _appendNonceScript(String nonce) {
  final script = _nonceScript(nonce);
  web.document.head!.append(script);
  return script;
}
