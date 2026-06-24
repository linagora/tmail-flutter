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
<head><meta charset="utf-8"><title>Drive Fake Picker</title>
<style>
  body { font-family: sans-serif; padding: 32px; }
  button {
    display: block; width: 200px; padding: 12px 0; margin: 12px 0;
    font-size: 15px; border-radius: 6px; border: none; cursor: pointer;
  }
  #btn-attachment { background: #1976d2; color: #fff; }
  #btn-link { background: #388e3c; color: #fff; }
</style>
</head>
<body>
<h3 style="color:#555">Drive Fake Picker</h3>
<button id="btn-attachment" onclick="sendAttachment()">Attachment</button>
<button id="btn-link" onclick="sendLink()">Link</button>
<script>
  function post(doc) {
    window.parent.postMessage(
      JSON.stringify({ type: 'intent-{INTENT_ID}:done', document: [doc] }),
      '*'
    );
  }
  function sendAttachment() {
    post({
      id: 'fake-attach-1',
      name: 'sample.pdf',
      size: 12345,
      mimeType: 'application/pdf',
      downloadLink: 'https://cdn.jsdelivr.net/gh/mozilla/pdf.js@master/examples/learning/helloworld.pdf'
    });
  }
  function sendLink() {
    post({
      id: 'fake-link-1',
      name: 'random-image.jpg',
      size: 0,
      mimeType: 'image/jpeg',
      sharingLink: 'https://picsum.photos/800/600'
    });
  }
</script>
</body>
</html>''';
}
