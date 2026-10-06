import 'dart:js_interop';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker_web/file_picker_web.dart';
import 'package:web/web.dart' as web;

/// cross_file's web `openRead` yields the whole blob as one chunk, so even a
/// bounded head probe would cost the full file. `WebPlatformFile` streams the
/// same `blob:` URL the picker path already streams.
Stream<List<int>> Function([int? start, int? end]) droppedFileOpenRead(
  XFile xFile,
) => ([start, end]) => WebPlatformFile(
      // The constructor rejects an empty name.
      name: xFile.name.isNotEmpty ? xFile.name : 'dropped-file',
      uri: Uri.parse(xFile.path),
    ).readAsByteStream();

/// `readAsByteStream` swallows fetch errors, so probe the blob URL directly: a folder's fetch rejects.
Future<bool> droppedFileIsReadable(XFile xFile) async {
  try {
    final response = await web.window.fetch(xFile.path.toJS).toDart;
    await response.body?.cancel().toDart;
    return response.ok;
  } catch (_) {
    return false;
  }
}
