import 'dart:typed_data';

import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';

/// The staging storage the transfer needs: create an entry, stream bytes into
/// it, read it back for upload, and clean up. The seam both the stager and the
/// uploader depend on, so neither names an OPFS API itself.
abstract interface class OpfsStore {
  Future<web.FileSystemFileHandle> createTempFile(String fileName);

  Future<web.File> getFile(OpfsFileHandle fileHandle);

  Future<Uint8List> readFilePrefix(web.File file, int maxBytes);

  Future<web.FileSystemWritableFileStream> openWritable(
      web.FileSystemFileHandle handle);

  Future<void> writeChunk(
      web.FileSystemWritableFileStream stream, Uint8List chunk);

  Future<void> closeWritable(web.FileSystemWritableFileStream stream);

  Future<void> abortWritable(web.FileSystemWritableFileStream stream);

  Future<void> removeTempFile(String fileName);

  Future<void> sweepStaleTempFiles({Duration olderThan});
}
