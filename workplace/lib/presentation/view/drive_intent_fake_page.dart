import 'dart:convert';

abstract final class DriveIntentFakePage {
  static String buildHtml(String intentId) =>
      _kTemplate.replaceAll('{INTENT_ID}', intentId);

  static Uri buildDataUri(String intentId) {
    final bytes = utf8.encode(buildHtml(intentId));
    return Uri.parse('data:text/html;base64,${base64Encode(bytes)}');
  }

  // Use '*' as targetOrigin so the message reaches the parent regardless of
  // its actual origin. On web, event.origin at the parent is still the iframe's
  // opaque 'null' origin, which the mixin validates against. On mobile the
  // JS shim forwards the targetOrigin literal ('*') as the origin argument,
  // handled by the special case in DriveIntentMessageHandlerMixin._isValidOrigin.
  static const String _kTemplate = '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Drive Intent Test</title></head>
<body>
<p style="font-family:sans-serif;padding:20px;color:#888">Drive intent test page — intent: {INTENT_ID}</p>
<script>
  var ackReceived = false;
  window.addEventListener('load', function() {
    console.log('[drive-fake] sending ready for intent-{INTENT_ID}');
    window.parent.postMessage(
      JSON.stringify({ type: 'intent-{INTENT_ID}:ready' }),
      '*'
    );
  });
  window.addEventListener('message', function(e) {
    if (ackReceived) return;
    ackReceived = true;
    console.log('[drive-fake] ack received, sending done for intent-{INTENT_ID} in 3s');
    setTimeout(function() {
      var doc = [{
        id: 'fake-doc-1',
        name: 'test-document.pdf',
        size: 1024,
        mimeType: 'application/pdf',
        downloadLink: 'https://example.com/fake/test-document.pdf'
      }];
      console.log('[drive-fake] sending done for intent-{INTENT_ID}, document:', JSON.stringify(doc, null, 2));
      window.parent.postMessage(
        JSON.stringify({ type: 'intent-{INTENT_ID}:done', document: doc }),
        '*'
      );
    }, 3000);
  });
</script>
</body>
</html>''';
}
