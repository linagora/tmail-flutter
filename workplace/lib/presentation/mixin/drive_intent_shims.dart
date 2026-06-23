abstract final class DriveIntentShims {
  static const String handlerName = 'driveIntentMessage';

  // The shim forwards `targetOrigin` (the value the page chose to pass to
  // postMessage) as the second arg to the Flutter handler. This is intentional:
  // mobile WebViews have no browser-stamped origin, so we use targetOrigin as a
  // best-effort hint. On web, `event.origin` is browser-stamped and trustworthy;
  // on mobile the origin check is inherently weaker because the page controls
  // the targetOrigin value. Mitigation: we only open URLs from trusted sources.
  static String get parentPostMessageShim => '''
    window.parent = {
      postMessage: function(data, targetOrigin) {
        window.flutter_inappwebview.callHandler(
          '$handlerName',
          typeof data === 'string' ? data : JSON.stringify(data),
          targetOrigin
        );
      }
    };
    ''';
}
