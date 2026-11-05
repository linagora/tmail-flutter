import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// dart:html wraps foreign-frame windows in fresh objects, so compare the native ones.
/// `==` would read a property of the cross-origin sandboxed window and throw.
bool isMessageFromIframe(Object event, Object? iframe) {
  if (iframe == null) return false;
  final messageEvent = (event as JSObject) as web.MessageEvent;
  final frameElement = (iframe as JSObject) as web.HTMLIFrameElement;
  final source = messageEvent.source;
  final frameWindow = frameElement.contentWindow;
  return source != null &&
      frameWindow != null &&
      source.strictEquals(frameWindow).toDart;
}
