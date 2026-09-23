import 'package:cross_file/cross_file.dart';
import 'package:file_picker_web/file_picker_web.dart';

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
