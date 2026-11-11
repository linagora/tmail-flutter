import 'package:core/utils/html/host_script_nonce.dart';
import 'package:web/web.dart' as web;

/// First script `.nonce` that matches the host nonce grammar.
String? readPlatformHostScriptNonce() {
  final scripts = web.document.scripts;
  for (var i = 0; i < scripts.length; i++) {
    final nonce = (scripts.item(i) as web.HTMLElement?)?.nonce;
    if (HostScriptNonce.isValid(nonce)) return nonce;
  }
  return null;
}
