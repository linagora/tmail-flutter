import 'dart:js_interop';
import 'dart:typed_data';

import 'package:model/upload/file_info.dart';
import 'package:web/web.dart' as web;

/// Mints a real `blob:` URL, like a web pick. `openRead` fails on purpose:
/// the upload must go through the blob adapter, never read the bytes in Dart.
FileInfo createBlobFileInfo(Uint8List bytes, String fileName, String mimeType) {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  return FileBlobInfo(
    fileName: fileName,
    fileSize: bytes.length,
    type: mimeType,
    sourceUrl: web.URL.createObjectURL(blob),
    openRead: ([start, end]) =>
        Stream<List<int>>.error(StateError('Blob upload read bytes in Dart')),
  );
}
