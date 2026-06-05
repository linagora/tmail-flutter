abstract final class DriveIntentShims {
  static const String handlerName = 'driveIntentMessage';

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
