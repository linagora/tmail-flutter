import 'dart:async';

typedef OnFileProcessedProgress = void Function(int processed, int total);

typedef OnDeleteIOFile = Future<void> Function(String path);
