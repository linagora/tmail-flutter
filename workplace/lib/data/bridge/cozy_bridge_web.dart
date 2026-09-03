// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// Read fresh on every access: setupBridge() replaces window._cozyBridge wholesale.
@JS('window._cozyBridge')
external JSObject? get _bridge;

@JS('JSON.stringify')
external String _stringify(JSAny? value);

extension type _CozyBridgeJs(JSObject _) implements JSObject {
  external JSPromise<JSAny?> fetchJSON(JSObject options);
}

/// Proxies requests through the cozy external bridge to the container app,
/// which owns the stack session — so no token exchange is needed.
abstract final class CozyBridge {
  /// Web reaches Drive only through the container app, never directly.
  static bool get isSupported => true;

  /// `fetchJSON` is only attached once `setupBridge` succeeds, so its presence
  /// also proves we are inside the container iframe.
  static bool get isAvailable => _bridge?.has('fetchJSON') ?? false;

  static Future<dynamic> fetchJson({
    required String method,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final bridge = _bridge;
    if (bridge == null) throw StateError('Cozy bridge unavailable');
    final options =
        {'method': method, 'path': path, 'body': body}.jsify() as JSObject;
    final result = await _CozyBridgeJs(bridge).fetchJSON(options).toDart;
    // JSON round-trip instead of dartify(), which would yield Map<Object?, Object?>.
    return result == null ? null : jsonDecode(_stringify(result));
  }
}
