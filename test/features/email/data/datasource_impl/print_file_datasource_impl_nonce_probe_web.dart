import 'package:web/web.dart' as web;

abstract class HostNonceScript {
  String? getAttribute(String name);
  void remove();
}

HostNonceScript insertHostNonceScript(String nonce) {
  final script = web.HTMLScriptElement()
    ..setAttribute('nonce', '')
    ..nonce = nonce;
  final head = web.document.head!;
  head.insertBefore(script, head.firstChild);
  return _WebHostNonceScript(script);
}

class _WebHostNonceScript implements HostNonceScript {
  _WebHostNonceScript(this._script);

  final web.HTMLScriptElement _script;

  @override
  String? getAttribute(String name) => _script.getAttribute(name);

  @override
  void remove() => _script.remove();
}
