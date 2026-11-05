import 'package:web/web.dart' as web;

final _validNonce = RegExp(r'^[A-Za-z0-9+/=_-]+$');

/// First script `.nonce` that matches the host nonce grammar.
String? readPlatformHostScriptNonce() {
  final scripts = web.document.scripts;
  for (var i = 0; i < scripts.length; i++) {
    final nonce = (scripts.item(i) as web.HTMLElement?)?.nonce;
    if (nonce != null && _validNonce.hasMatch(nonce)) return nonce;
  }
  return null;
}
