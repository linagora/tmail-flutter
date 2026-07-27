@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';

/// `FileSystemFileHandle.prototype`, the object `isOpfsSupported` probes.
JSObject get _fileHandlePrototype =>
    (globalContext['FileSystemFileHandle'] as JSObject)['prototype'] as JSObject;

void main() {
  group('OpfsJsBindings.isOpfsSupported', () {
    test('is true on a browser exposing getDirectory and createWritable', () {
      expect(OpfsJsBindings().isOpfsSupported(), isTrue);
    });

    test('is false when createWritable is missing, as on Safari before 26', () {
      // Chrome ships both halves, so the only way to exercise the
      // createWritable branch is to take it away: hide the prototype method
      // for the duration of this test, then put it back.
      final prototype = _fileHandlePrototype;
      final original = prototype['createWritable'];
      addTearDown(() => prototype['createWritable'] = original);
      prototype['createWritable'] = null;

      expect(OpfsJsBindings().isOpfsSupported(), isFalse);
    });
  });
}
