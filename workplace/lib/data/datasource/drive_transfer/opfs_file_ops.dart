import 'dart:js_interop';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_store.dart';

/// Marks an OPFS entry as this package's, so [OpfsFileOps.sweepStaleTempFiles]
/// leaves the origin's other data alone.
const opfsTempFilePrefix = 'tmail_drive_';

/// `FileSystemDirectoryHandle.keys()` — the only way to enumerate OPFS
/// entries, and `package:web` ships no binding for it.
extension type _DirectoryHandleKeys(JSObject _) implements JSObject {
  external _AsyncStringIterator keys();
}

extension type _AsyncStringIterator(JSObject _) implements JSObject {
  external JSPromise<_AsyncIterationResult> next();
}

extension type _AsyncIterationResult(JSObject _) implements JSObject {
  external bool get done;

  external String? get value;
}

/// Creating, writing, reading back and removing OPFS staging entries.
class OpfsFileOps implements OpfsStore {
  Future<web.FileSystemDirectoryHandle> _opfsRoot() =>
      web.window.navigator.storage.getDirectory().toDart;

  @override
  Future<web.FileSystemFileHandle> createTempFile(String fileName) async {
    final root = await _opfsRoot();
    return root
        .getFileHandle(fileName, web.FileSystemGetFileOptions(create: true))
        .toDart;
  }

  /// The `web.File` snapshot the uploader sends. Kept here so narrowing
  /// [OpfsFileHandle] to its web type is the bindings' job alone.
  @override
  Future<web.File> getFile(OpfsFileHandle fileHandle) =>
      (fileHandle as web.FileSystemFileHandle).getFile().toDart;

  /// The first [maxBytes] of [file], for charset detection. Sliced rather than
  /// read whole: the staged document is only ever meant to reach the JS heap
  /// one chunk at a time.
  @override
  Future<Uint8List> readFilePrefix(web.File file, int maxBytes) async {
    final buffer = await file.slice(0, maxBytes).arrayBuffer().toDart;
    return buffer.toDart.asUint8List();
  }

  @override
  Future<web.FileSystemWritableFileStream> openWritable(
      web.FileSystemFileHandle handle) =>
      handle.createWritable().toDart;

  @override
  Future<void> writeChunk(
      web.FileSystemWritableFileStream stream, Uint8List chunk) =>
      stream.write(chunk.toJS).toDart;

  @override
  Future<void> closeWritable(web.FileSystemWritableFileStream stream) =>
      stream.close().toDart;

  @override
  Future<void> abortWritable(web.FileSystemWritableFileStream stream) =>
      stream.abort().toDart;

  @override
  Future<void> removeTempFile(String fileName) async {
    final root = await _opfsRoot();
    await root.removeEntry(fileName).toDart;
  }

  /// Removes staging entries left behind by a tab that died mid-transfer:
  /// OPFS is persistent, and neither `OpfsStagedFile.dispose()` nor the
  /// stager's failure cleanup runs on a crash.
  ///
  /// [olderThan] keeps the sweep safe while another tab of the same origin is
  /// mid-transfer — its entries are minutes old, orders of magnitude inside the
  /// window even at four hours. Per-entry failures are logged, never rethrown.
  @override
  Future<void> sweepStaleTempFiles({
    Duration olderThan = const Duration(hours: 4),
  }) async {
    final root = await _opfsRoot();
    final cutoff = DateTime.now().subtract(olderThan);
    final iterator = (root as _DirectoryHandleKeys).keys();
    // Collected first: removing entries while iterating the same directory is
    // not guaranteed to leave the iteration stable, which can skip entries.
    final staleNames = <String>[];
    while (true) {
      final step = await iterator.next().toDart;
      if (step.done) break;
      final name = step.value;
      if (name == null || !_isStaleTempFile(name, cutoff)) continue;
      staleNames.add(name);
    }
    for (final name in staleNames) {
      try {
        await root.removeEntry(name).toDart;
      } catch (e) {
        logWarning('OpfsFileOps: failed to sweep stale temp file $name: $e');
      }
    }
  }
}

/// Names are `<prefix><microsSinceEpoch>_...`. A name that doesn't parse is
/// left alone.
bool _isStaleTempFile(String name, DateTime cutoff) {
  if (!name.startsWith(opfsTempFilePrefix)) return false;
  final micros = int.tryParse(
      name.substring(opfsTempFilePrefix.length).split('_').first);
  if (micros == null) return false;
  return DateTime.fromMicrosecondsSinceEpoch(micros).isBefore(cutoff);
}
