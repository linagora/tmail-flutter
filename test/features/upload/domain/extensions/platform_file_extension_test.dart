import 'dart:typed_data';

import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';

/// A minimal concrete [PlatformFile]: the class is abstract in file_picker
/// 13.x, so a test double has to implement it rather than construct one.
base class _FakePlatformFile extends PlatformFile {
  /// Mirrors how the real picker distinguishes platforms: a local pick's
  /// `uri` has the `file:` scheme, so the inherited `path` getter
  /// (`uri.scheme == 'file' ? uri.toFilePath() : null`) resolves it; a web
  /// pick's `uri` is a `blob:` URL, for which that getter is always null.
  ///
  /// [syncSize] and [asyncSize] are kept separate so a test can make
  /// `lengthSync()` report nothing while `length()` still resolves — the
  /// case a picker that reports no size upfront actually hits.
  _FakePlatformFile({
    required this.name,
    String? path,
    int? syncSize,
    int? asyncSize,
    Stream<Uint8List>? readStream,
  }) : _uri = path != null ? Uri.file(path) : Uri.parse('blob:http://localhost/$name'),
       _syncSize = syncSize,
       _asyncSize = asyncSize ?? syncSize,
       _readStream = readStream ?? const Stream.empty();

  @override
  final String name;
  final Uri _uri;
  final int? _syncSize;
  final int? _asyncSize;
  final Stream<Uint8List> _readStream;

  int readAsBytesCallCount = 0;
  int readAsByteStreamCallCount = 0;

  @override
  Uri get uri => _uri;

  @override
  int? lengthSync() => _syncSize;

  @override
  Future<int?> length() async => _asyncSize;

  @override
  Future<Uint8List> readAsBytes() async {
    readAsBytesCallCount++;
    return Uint8List(0);
  }

  @override
  Stream<Uint8List> readAsByteStream() {
    readAsByteStreamCallCount++;
    return _readStream;
  }

  @override
  get xFile => throw UnsupportedError('not used by this test');
}

void main() {
  test('drops a picked blob URL, since path is null for a web pick', () async {
    final platformFile = _FakePlatformFile(name: 'a.pdf', path: null, syncSize: 10);

    final fileInfo = await platformFile.toFileInfo();

    // WebPlatformFile.path is always null (file_picker_web.dart); off web, no
    // path means no readable source at all.
    expect(fileInfo, isA<FilePlaceholderInfo>());
  });

  test('reads size without reading any bytes', () async {
    final platformFile = _FakePlatformFile(name: 'a.pdf', syncSize: 2048);

    final fileInfo = await platformFile.toFileInfo();

    expect(fileInfo.fileSize, 2048);
    expect(platformFile.readAsBytesCallCount, 0);
    expect(platformFile.readAsByteStreamCallCount, 0);
  });

  test('falls back to length() when the picker reports no size', () async {
    final platformFile = _FakePlatformFile(name: 'a.pdf', syncSize: null, asyncSize: 2048);

    final fileInfo = await platformFile.toFileInfo();

    expect(fileInfo.fileSize, 2048);
    expect(platformFile.readAsBytesCallCount, 0);
  });

  test('throws FileSizeUnavailableException when length() also reports no size', () async {
    final platformFile = _FakePlatformFile(name: 'a.pdf', syncSize: null, asyncSize: null);

    expect(
      () => platformFile.toFileInfo(),
      throwsA(isA<FileSizeUnavailableException>()),
    );
  });

  test('carries openRead through as the readAsByteStream tear-off', () async {
    PlatformInfo.isTestingForWeb = true;
    addTearDown(() => PlatformInfo.isTestingForWeb = false);
    final readStream = Stream<Uint8List>.value(Uint8List.fromList([1, 2, 3]));
    final platformFile = _FakePlatformFile(name: 'a.pdf', syncSize: 3, readStream: readStream);

    final fileInfo = await platformFile.toFileInfo();

    expect(fileInfo, isA<FileBlobInfo>());
    expect(fileInfo.openRead(), same(readStream));
    expect(platformFile.readAsByteStreamCallCount, 1);
  });

  test('keeps the file path on non-web platforms', () async {
    final platformFile = _FakePlatformFile(name: 'a.pdf', path: '/tmp/a.pdf', syncSize: 10);

    final fileInfo = await platformFile.toFileInfo();

    expect((fileInfo as FilePathInfo).filePath, '/tmp/a.pdf');
  });
}
