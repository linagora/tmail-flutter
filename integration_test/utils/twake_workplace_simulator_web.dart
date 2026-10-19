import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Installs a fake cozy-external-bridge that reports the app as embedded in
/// Twake Workplace. The e2e env leaves COZY_INTEGRATION empty, so the real
/// bridge is never loaded over it; each test runs on a fresh page.
void simulateTwakeWorkplace() {
  final parentOrigin = web.window.location.origin;
  final bridge = JSObject()
    ..['requestParentOrigin'] = (() => Future.value(parentOrigin.toJS).toJS).toJS
    ..['isInsideCozy'] = ((JSString _) => true.toJS).toJS;
  globalContext['_cozyBridge'] = bridge;
}
