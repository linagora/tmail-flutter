import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// A [PlatformFile] backed by a real [File] on disk. The class is abstract in
/// file_picker 13.x, so faking a pick needs a concrete implementation rather
/// than constructing one directly.
base class FakePlatformFile extends PlatformFile {
  FakePlatformFile(this._file);

  final File _file;

  @override
  String get name => _file.path.split(Platform.pathSeparator).last;

  @override
  Uri get uri => _file.uri;

  @override
  int? lengthSync() {
    try {
      return _file.lengthSync();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int?> length() async {
    try {
      return await _file.length();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Uint8List> readAsBytes() => _file.readAsBytes();

  @override
  Stream<Uint8List> readAsByteStream() =>
      _file.openRead().map(Uint8List.fromList);

  @override
  get xFile => throw UnsupportedError('not used by this robot');
}

/// A [FilePickerPlatform] double must `extends` (not `implements`) the base
/// class: its constructor registers this instance against the platform
/// interface's private token, which `instance =` verifies on assignment.
class FakeFilePicker extends FilePickerPlatform {
  final List<PlatformFile> _result;

  FakeFilePicker(this._result);

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => _result.isEmpty ? null : _result.first;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => _result;
}
