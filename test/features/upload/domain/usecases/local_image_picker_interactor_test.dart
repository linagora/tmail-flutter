import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_image_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_image_picker_interactor.dart';

/// A null [_size] mimics a picker that cannot report a size.
base class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile(this.name, this._size);

  @override
  final String name;
  final int? _size;

  @override
  Uri get uri => Uri.parse(name);

  @override
  int? lengthSync() => _size;

  @override
  Future<int?> length() async => _size;

  @override
  Future<Uint8List> readAsBytes() =>
      throw UnsupportedError('not used by this test');

  @override
  Stream<Uint8List> readAsByteStream() =>
      throw UnsupportedError('not used by this test');

  @override
  get xFile => throw UnsupportedError('not used by this test');
}

class _SingleFilePickerPlatform extends FilePickerPlatform {
  _SingleFilePickerPlatform(this._result);

  final PlatformFile? _result;

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
  }) async => _result;
}

Future<Object?> _lastFailureException() async {
  final states = await LocalImagePickerInteractor().execute().toList();
  final failure = states.last.fold((failure) => failure, (_) => null);
  return (failure as LocalImagePickerFailure).exception;
}

void main() {
  test('yields the picked image as FileInfo', () async {
    FilePickerPlatform.instance =
        _SingleFilePickerPlatform(_FakePlatformFile('a.png', 2048));

    final states = await LocalImagePickerInteractor().execute().toList();

    final success = states.last.fold((_) => null, (success) => success)
        as LocalImagePickerSuccess;
    expect(success.fileInfo.fileName, 'a.png');
    expect(success.fileInfo.fileSize, 2048);
  });

  test('fails with FileSizeUnavailableException when the picked image has no size', () async {
    FilePickerPlatform.instance =
        _SingleFilePickerPlatform(_FakePlatformFile('a.png', null));

    expect(await _lastFailureException(), isA<FileSizeUnavailableException>());
  });

  test('fails with PickFileCanceledException when nothing is picked', () async {
    FilePickerPlatform.instance = _SingleFilePickerPlatform(null);

    expect(await _lastFailureException(), isA<PickFileCanceledException>());
  });
}
