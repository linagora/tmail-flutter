import 'dart:async';

typedef OnFileProcessedProgress = void Function(int processed, int total);

typedef OnDeleteIOFile = Future<void> Function(String path);
typedef OnDeleteOPFSFile = Future<void> Function(Object handle);