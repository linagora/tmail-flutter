abstract class HostNonceScript {
  String? getAttribute(String name);
  void remove();
}

HostNonceScript insertHostNonceScript(String nonce) =>
    throw UnsupportedError('host nonce script is web-only');
