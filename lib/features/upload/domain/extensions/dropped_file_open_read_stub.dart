import 'package:cross_file/cross_file.dart';

/// Native `XFile.openRead` already streams from disk, range included.
Stream<List<int>> Function([int? start, int? end]) droppedFileOpenRead(
  XFile xFile,
) => ([start, end]) => xFile.openRead(start, end);

/// A folder cannot be opened, so reading its first byte throws.
Future<bool> droppedFileIsReadable(XFile xFile) async {
  try {
    await xFile.openRead(0, 1).drain<void>();
    return true;
  } catch (_) {
    return false;
  }
}
