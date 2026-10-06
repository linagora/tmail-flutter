import 'dart:async';
import 'dart:typed_data';

import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/web_pick_options.dart';

/// A minimal concrete [PlatformFile]: the class is abstract in file_picker
/// 13.x, so a test double has to implement it rather than construct one.
///
/// [readAsByteStream] mints a fresh stream per call, mirroring the real web
/// path (`fetchStreamFromWebPath` re-fetches the blob URL every time) —
/// a canned single-subscription stream would let this double pass while
/// hiding a regression to a one-shot source.
base class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile(this.name, this._size, this._bytes);

  @override
  final String name;
  final int _size;
  final Uint8List _bytes;

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
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);

  @override
  get xFile => throw UnsupportedError('not used by this test');
}

/// A [FilePickerPlatform] double must `extends` (not `implements`) the base
/// class: its constructor registers this instance against the platform
/// interface's private token, which `instance =` verifies on assignment.
class _RecordingFilePickerPlatform extends FilePickerPlatform {
  _RecordingFilePickerPlatform(this._result);

  final List<PlatformFile> _result;
  WebOptions? capturedWebOptions;

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
  }) async {
    capturedWebOptions = webOptions;
    return _result;
  }
}

void main() {
  test('picks files as a stream, never buffering bytes upfront', () async {
    PlatformInfo.isTestingForWeb = true;
    addTearDown(() => PlatformInfo.isTestingForWeb = false);
    final picker = _RecordingFilePickerPlatform([
      _FakePlatformFile('a.pdf', 2048, Uint8List.fromList([1, 2, 3])),
    ]);
    FilePickerPlatform.instance = picker;

    final states = await LocalFilePickerInteractor().execute().toList();

    // Web-specific values are asserted in web_pick_options_web_test.dart.
    expect(picker.capturedWebOptions, same(lazyWebPickOptions()));

    final success = states
        .map((either) => either.fold((_) => null, (success) => success))
        .whereType<LocalFilePickerSuccess>()
        .single;
    final fileInfo = success.pickedFiles.single as FileBlobInfo;
    expect(fileInfo.fileName, 'a.pdf');
    expect(fileInfo.fileSize, 2048);

    // Calling openRead twice proves the source is a re-openable factory, not
    // a one-shot stream — the property this PR turns retry on.
    final firstRead = await fileInfo.openRead().toList();
    final secondRead = await fileInfo.openRead().toList();
    expect(firstRead, [[1, 2, 3]]);
    expect(secondRead, [[1, 2, 3]]);
  });

  test('yields a cancel failure when the picker returns nothing', () async {
    FilePickerPlatform.instance = _RecordingFilePickerPlatform([]);

    final states = await LocalFilePickerInteractor().execute().toList();

    final failure = states
        .map((either) => either.fold((failure) => failure, (_) => null))
        .whereType<LocalFilePickerFailure>()
        .single;
    expect(failure.exception, isA<PickFileCanceledException>());
  });
}
