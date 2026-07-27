@TestOn('chrome')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader_web.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_xhr_upload.dart';

web.File _fakeFile() => web.File(<web.BlobPart>[].toJS, 'test.txt');

/// The fake bindings below stub `getFile`, so the handle is never
/// dereferenced — a bare JS object standing in for the type is enough.
web.FileSystemFileHandle _fakeFileHandle() =>
    JSObject() as web.FileSystemFileHandle;

/// One request shape for every case here; only the cancel token ever differs.
OpfsUploadRequest _uploadRequest({CancelToken? cancelToken}) =>
    OpfsUploadRequest(
      fileHandle: _fakeFileHandle(),
      fileName: 'hello.txt',
      uploadUri: Uri.parse('https://jmap.example/upload'),
      authHeader: 'Bearer token',
      mimeType: 'text/plain',
      onUploadProgress: (_, __) {},
      cancelToken: cancelToken ?? CancelToken(),
    );

void main() {
  test('resolves with an Attachment when the upload succeeds', () async {
    OpfsJsBindings.setInstance(_FakeSuccessfulOpfsJsBindings());

    final attachment =
        await BrowserOpfsDriveFileUploader().upload(_uploadRequest());

    expect(attachment.name, 'hello.txt');
    expect(attachment.size?.value, 42);
  });

  // The fake fails with a bare StateError, so this also pins that a failure on
  // a live token passes through untouched — only a cancelled token is rewritten.
  test('propagates an error when the upload fails', () async {
    OpfsJsBindings.setInstance(_FakeFailingOpfsJsBindings());

    await expectLater(
      BrowserOpfsDriveFileUploader().upload(_uploadRequest()),
      throwsA(isA<StateError>()),
    );
  });

  test('calling cancel aborts the in-flight upload', () async {
    final bindings = _FakeAbortableOpfsJsBindings();
    OpfsJsBindings.setInstance(bindings);
    final cancelToken = CancelToken();

    final upload = BrowserOpfsDriveFileUploader()
        .upload(_uploadRequest(cancelToken: cancelToken));

    // Let the upload progress past its own cancellation checks and create
    // the XHR before cancelling, so this exercises the whenCancel -> abort
    // wiring rather than the pre-XHR cancellation guard.
    await Future<void>.delayed(Duration.zero);
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

    final upload = BrowserOpfsDriveFileUploader()
        .upload(_uploadRequest(cancelToken: cancelToken));

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
  @override
  Future<web.File> getFile(Object fileHandle) async => _fakeFile();
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
  bool uploadFileCalled = false;

  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    uploadFileCalled = true;
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
