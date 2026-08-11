@TestOn('chrome')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:core/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader_web.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_xhr_upload.dart';

web.File _fakeFile([String content = '']) =>
    web.File(<web.BlobPart>[content.toJS].toJS, 'test.txt');

/// Stands in for the real detector, which is a platform channel with nothing
/// behind it in a browser test.
class _FakeFileUtils extends FileUtils {
  _FakeFileUtils(this.charset);

  final String charset;
  final sniffedByteCounts = <int>[];

  @override
  Future<String> getCharsetFromBytes(Uint8List bytes) async {
    sniffedByteCounts.add(bytes.length);
    return charset;
  }
}

/// The fake bindings below stub `getFile`, so the handle is never
/// dereferenced — a bare JS object standing in for the type is enough.
web.FileSystemFileHandle _fakeFileHandle() =>
    JSObject() as web.FileSystemFileHandle;

/// One request shape for every case here; only the cancel token and the mime
/// type ever differ.
OpfsUploadRequest _uploadRequest({
  CancelToken? cancelToken,
  String? mimeType = 'text/plain',
}) =>
    OpfsUploadRequest(
      fileHandle: _fakeFileHandle(),
      fileName: 'hello.txt',
      uploadUri: Uri.parse('https://jmap.example/upload'),
      authHeader: 'Bearer token',
      mimeType: mimeType,
      onUploadProgress: (_, __) {},
      cancelToken: cancelToken ?? CancelToken(),
    );

/// Charset detection is a platform channel with nothing behind it in a browser
/// test, so every case that isn't about the charset gets a fake detector.
BrowserOpfsDriveFileUploader _uploader() =>
    BrowserOpfsDriveFileUploader(fileUtils: _FakeFileUtils('utf-8'));

void main() {
  test('resolves with an Attachment when the upload succeeds', () async {
    OpfsJsBindings.setInstance(_FakeSuccessfulOpfsJsBindings());

    final attachment =
        await _uploader().upload(_uploadRequest());

    expect(attachment.name, 'hello.txt');
    expect(attachment.size?.value, 42);
  });

  test('detects the charset of a text/plain document from a prefix', () async {
    OpfsJsBindings.setInstance(
        _FakeSuccessfulOpfsJsBindings()..fileContent = 'hello opfs');
    final fileUtils = _FakeFileUtils('ISO-8859-1');

    final attachment = await BrowserOpfsDriveFileUploader(fileUtils: fileUtils)
        .upload(_uploadRequest());

    // Lowercased, the way `FileUploader` stores it.
    expect(attachment.charset, 'iso-8859-1');
    expect(fileUtils.sniffedByteCounts, ['hello opfs'.length]);
  });

  test('leaves the charset unset for a non-text document', () async {
    OpfsJsBindings.setInstance(
        _FakeSuccessfulOpfsJsBindings()..fileContent = 'hello opfs');
    final fileUtils = _FakeFileUtils('ISO-8859-1');

    final attachment = await BrowserOpfsDriveFileUploader(fileUtils: fileUtils)
        .upload(_uploadRequest(mimeType: 'application/pdf'));

    expect(attachment.charset, isNull);
    expect(fileUtils.sniffedByteCounts, isEmpty);
  });

  // The fake fails with a bare StateError, so this also pins that a failure on
  // a live token passes through untouched — only a cancelled token is rewritten.
  test('propagates an error when the upload fails', () async {
    OpfsJsBindings.setInstance(_FakeFailingOpfsJsBindings());

    await expectLater(
      _uploader().upload(_uploadRequest()),
      throwsA(isA<StateError>()),
    );
  });

  test('calling cancel aborts the in-flight upload', () async {
    final bindings = _FakeAbortableOpfsJsBindings();
    OpfsJsBindings.setInstance(bindings);
    final cancelToken = CancelToken();

    final upload = _uploader().upload(_uploadRequest(cancelToken: cancelToken));

    // Waits for the XHR to actually exist rather than for a fixed number of
    // microtasks, so this keeps exercising the whenCancel -> abort wiring —
    // and not the pre-XHR guard — however many awaits precede the upload.
    await bindings.uploadFileStarted;
    cancelToken.cancel();

    // The same error a cancel before the XHR existed produces.
    await expectLater(
      upload,
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.cancel)),
    );
    expect(bindings.aborted, isTrue);
  });

  test('does not create the XHR when cancelled while getFile is pending',
      () async {
    final bindings = _FakeDeferredGetFileOpfsJsBindings();
    OpfsJsBindings.setInstance(bindings);
    final cancelToken = CancelToken();

    final upload = _uploader().upload(_uploadRequest(cancelToken: cancelToken));

    // getFile has started (and is pending) by the time this runs; cancel
    // here exercises the *second* guard, after getFile resolves, not the
    // pre-getFile one.
    await Future<void>.delayed(Duration.zero);
    cancelToken.cancel();
    bindings.completeGetFile();

    await expectLater(upload, throwsA(isA<DioException>()));
    expect(bindings.uploadFileCalled, isFalse);
  });
}

/// The file is never read, only handed to `uploadFile`, so every fake stubs
/// `getFile` the same way and varies only the upload half.
abstract class _FakeOpfsJsBindings extends OpfsJsBindings {
  /// Only the charset cases care what is in the file; everything else uploads
  /// an empty one.
  String fileContent = '';

  @override
  Future<web.File> getFile(Object fileHandle) async => _fakeFile(fileContent);
}

class _FakeSuccessfulOpfsJsBindings extends _FakeOpfsJsBindings {
  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    return XhrUploadHandle(
      response: Future.value({
        'accountId': 'account-1',
        'blobId': 'blob-1',
        'type': 'text/plain',
        'size': 42,
      }),
      abort: () {},
    );
  }
}

class _FakeFailingOpfsJsBindings extends _FakeOpfsJsBindings {
  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    return XhrUploadHandle(
      response: Future.error(StateError('upload failed')),
      abort: () {},
    );
  }
}

class _FakeDeferredGetFileOpfsJsBindings extends _FakeOpfsJsBindings {
  bool uploadFileCalled = false;
  final _getFileCompleter = Completer<web.File>();

  void completeGetFile() => _getFileCompleter.complete(_fakeFile());

  @override
  Future<web.File> getFile(Object fileHandle) => _getFileCompleter.future;

  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    uploadFileCalled = true;
    return XhrUploadHandle(
      response: Future.value(<String, dynamic>{}),
      abort: () {},
    );
  }
}

class _FakeAbortableOpfsJsBindings extends _FakeOpfsJsBindings {
  bool aborted = false;
  final _uploadFileStarted = Completer<void>();

  /// Resolves once the XHR exists, i.e. once cancelling can only go through
  /// the abort wiring.
  Future<void> get uploadFileStarted => _uploadFileStarted.future;

  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    if (!_uploadFileStarted.isCompleted) _uploadFileStarted.complete();
    final completer = Completer<Map<String, dynamic>>();
    return XhrUploadHandle(
      response: completer.future,
      abort: () {
        aborted = true;
        if (!completer.isCompleted) {
          completer.completeError(StateError('OPFS upload cancelled'));
        }
      },
    );
  }
}
