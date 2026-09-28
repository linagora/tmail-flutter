import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';

/// A [File] whose reads come from a scripted [FileOpenRead].
class ScriptedReadFile extends Fake implements File {
  ScriptedReadFile(this.path, this._openRead);

  @override
  final String path;
  final FileOpenRead _openRead;

  @override
  Stream<List<int>> openRead([int? start, int? end]) => _openRead(start, end);
}

/// Runs [body] with `File(path)` for each key of [readers] served by its reader,
/// so a [FilePathInfo] can drive a scripted stream through the real upload path.
Future<T> withScriptedFiles<T>(Map<String, FileOpenRead> readers, Future<T> Function() body) =>
  IOOverrides.runZoned(
    body,
    createFile: (path) {
      final reader = readers[path];
      if (reader == null) throw StateError('Unscripted file: $path');
      return ScriptedReadFile(path, reader);
    },
  );
