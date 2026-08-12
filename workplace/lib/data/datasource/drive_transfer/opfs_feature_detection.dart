import 'dart:js_interop';

import 'package:core/utils/app_logger.dart';
import 'package:web/web.dart' as web;

/// Reads `getDirectory` without invoking it, so detection stays synchronous
/// and creates no probe file.
extension type _StorageManagerFeatureProbe(JSObject _) implements JSObject {
  external JSAny? get getDirectory;
}

/// `navigator.storage` as a nullable value: it is absent in insecure contexts,
/// where `web.Navigator.storage` hands back `undefined` and blows up on the
/// next property read.
extension type _NavigatorStorageProbe(JSObject _) implements JSObject {
  external _StorageManagerFeatureProbe? get storage;
}

/// Nullable: reading an undefined property off `globalThis` yields null
/// rather than throwing.
@JS('FileSystemFileHandle')
external _FileSystemFileHandleCtorProbe? get _fileSystemFileHandleCtor;

extension type _FileSystemFileHandleCtorProbe(JSObject _) implements JSObject {
  external _FileSystemFileHandleProtoProbe? get prototype;
}

/// Reads `createWritable` off the prototype without invoking it.
extension type _FileSystemFileHandleProtoProbe(JSObject _) implements JSObject {
  external JSAny? get createWritable;
}

/// Whether this browser can run the OPFS transfer strategy at all. The seam
/// `DriveTransferStrategyFactory` probes, and the one tests swap.
abstract interface class OpfsCapability {
  bool isOpfsSupported();
}

/// Decides whether the OPFS transfer strategy can run at all.
class OpfsFeatureDetection implements OpfsCapability {
  /// True when both halves of the write path are present. Safari shipped
  /// `getDirectory` several releases before `createWritable` (Baseline only
  /// with Safari 26.0), so checking the former alone lets those versions
  /// through and then fails at `openWritable`, fallback never selected.
  ///
  /// Property reads only, so callers can cache this once per session.
  ///
  /// Guarded: an unsupported browser must select the buffered fallback, never
  /// fail the transfer, so anything unexpected out of the probe reads as false.
  @override
  bool isOpfsSupported() {
    try {
      final storage =
          (web.window.navigator as _NavigatorStorageProbe).storage;
      if (storage == null) return false;
      if (storage.getDirectory == null) return false;
      return _fileSystemFileHandleCtor?.prototype?.createWritable != null;
    } catch (e) {
      logWarning('OpfsFeatureDetection::isOpfsSupported: probe failed: $e');
      return false;
    }
  }
}
