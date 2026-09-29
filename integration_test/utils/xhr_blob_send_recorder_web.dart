import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

final _blobSendSizes = <int>[];
var _installed = false;

/// Wraps `XMLHttpRequest.send` once; records the size of every `Blob` body.
void recordXhrBlobSends() {
  _blobSendSizes.clear();
  if (_installed) return;
  _installed = true;
  final prototype = (globalContext['XMLHttpRequest'] as JSObject)['prototype'] as JSObject;
  final originalSend = prototype['send'] as JSFunction;
  prototype['send'] = ((JSObject xhr, [JSAny? body]) {
    if (body != null && body.isA<web.Blob>()) {
      _blobSendSizes.add((body as web.Blob).size);
    }
    originalSend.callAsFunction(xhr, body);
  }).toJSCaptureThis;
}

List<int> get recordedXhrBlobSendSizes => List.unmodifiable(_blobSendSizes);
