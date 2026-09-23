import 'package:cross_file/cross_file.dart';

/// Native `XFile.openRead` already streams from disk, range included.
Stream<List<int>> Function([int? start, int? end]) droppedFileOpenRead(
  XFile xFile,
) => ([start, end]) => xFile.openRead(start, end);
