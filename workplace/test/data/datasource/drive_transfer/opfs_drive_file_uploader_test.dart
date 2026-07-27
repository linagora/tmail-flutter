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

web.File _fakeFile() => web.File(<web.BlobPart>[].toJS, 'test.txt');

void main() {
  test('resolves with an Attachment when the upload succeeds', () async {
    OpfsJsBindings.setInstance(_FakeSuccessfulOpfsJsBindings());

    final attachment = await BrowserOpfsDriveFileUploader().upload(OpfsUploadRequest(
      fileHandle: Object(),
      fileName: 'hello.txt',
      uploadUri: Uri.parse('https://jmap.example/upload'),
      authHeader: 'Bearer token',
      onUploadProgress: (_, __) {},
      cancelToken: CancelToken(),
    ));

    expect(attachment.name, 'hello.txt');
    expect(attachment.size?.value, 42);
  });

  test('propagates an error when the upload fails', () async {
    OpfsJsBindings.setInstance(_FakeFailingOpfsJsBindings());

    await expectLater(
      BrowserOpfsDriveFileUploader().upload(OpfsUploadRequest(
        fileHandle: Object(),
        fileName: 'hello.txt',
        uploadUri: Uri.parse('https://jmap.example/upload'),
        authHeader: 'Bearer token',
        onUploadProgress: (_, __) {},
        cancelToken: CancelToken(),
      )),
      throwsA(isA<StateError>()),
    );
  });

  test('calling cancel aborts the in-flight upload', () async {
    final bindings = _FakeAbortableOpfsJsBindings();
    OpfsJsBindings.setInstance(bindings);
    final cancelToken = CancelToken();

    final upload = BrowserOpfsDriveFileUploader().upload(OpfsUploadRequest(
      fileHandle: Object(),
      fileName: 'hello.txt',
      uploadUri: Uri.parse('https://jmap.example/upload'),
      authHeader: 'Bearer token',
      onUploadProgress: (_, __) {},
      cancelToken: cancelToken,
    ));

    // Let the upload progress past its own cancellation checks and create
    // the XHR before cancelling, so this exercises the whenCancel -> abort
    // wiring rather than the pre-XHR cancellation guard.
    await Future<void>.delayed(Duration.zero);
    cancelToken.cancel();

    await expectLater(upload, throwsA(isA<StateError>()));
    expect(bindings.aborted, isTrue);
  });

  test('does not create the XHR when cancelled while getFile is pending',
      () async {
    final bindings = _FakeDeferredGetFileOpfsJsBindings();
    OpfsJsBindings.setInstance(bindings);
    final cancelToken = CancelToken();

    final upload = BrowserOpfsDriveFileUploader().upload(OpfsUploadRequest(
      fileHandle: Object(),
      fileName: 'hello.txt',
      uploadUri: Uri.parse('https://jmap.example/upload'),
      authHeader: 'Bearer token',
      onUploadProgress: (_, __) {},
      cancelToken: cancelToken,
    ));

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

class _FakeSuccessfulOpfsJsBindings extends OpfsJsBindings {
  @override
  Future<web.File> getFile(Object fileHandle) async => _fakeFile();

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

class _FakeFailingOpfsJsBindings extends OpfsJsBindings {
  @override
  Future<web.File> getFile(Object fileHandle) async => _fakeFile();

  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    return XhrUploadHandle(
      response: Future.error(StateError('upload failed')),
      abort: () {},
    );
  }
}

class _FakeDeferredGetFileOpfsJsBindings extends OpfsJsBindings {
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

class _FakeAbortableOpfsJsBindings extends OpfsJsBindings {
  bool aborted = false;
  bool uploadFileCalled = false;

  @override
  Future<web.File> getFile(Object fileHandle) async => _fakeFile();

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
