/// Non-web fallback: there is no cozy external bridge outside the browser.
abstract final class CozyBridge {
  static bool get isSupported => false;

  static bool get isAvailable => false;

  static Future<dynamic> fetchJson({
    required String method,
    required String path,
    required Map<String, dynamic> body,
  }) =>
      throw UnsupportedError('Cozy bridge is only available on web');
}
