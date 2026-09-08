// ignore_for_file: avoid_web_libraries_in_flutter

// Only ever imported from @TestOn('chrome') test files.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('window')
external JSObject get _window;

/// Installs a fake `window._cozyBridge.fetchJSON` so `CozyBridge.isAvailable`
/// is true. `handler` returning normally resolves the fake promise; throwing
/// rejects it, simulating a bridge-side failure.
void installCozyBridge(JSAny? Function(JSObject options) handler) {
  // Run handler() inside the computation so a throw rejects the future
  // instead of escaping synchronously before the promise is even built.
  JSPromise<JSAny?> fetchJson(JSObject options) =>
      Future<JSAny?>(() => handler(options)).toJS;

  final bridge = JSObject();
  bridge['fetchJSON'] = fetchJson.toJS;
  _window['_cozyBridge'] = bridge;
}

/// Removes the bridge so `CozyBridge.isAvailable` is false
/// (`isSupported` stays true on chrome).
void removeCozyBridge() => _window['_cozyBridge'] = null;
