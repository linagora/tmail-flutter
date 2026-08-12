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
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_store.dart';
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

/// The fakes below stub `getFile`, so the handle is never dereferenced — a
/// bare JS object standing in for the type is enough.
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
BrowserOpfsDriveFileUploader _uploader({
  OpfsStore? store,
  required DriveUploadTransport transport,
  FileUtils? fileUtils,
}) =>
    BrowserOpfsDriveFileUploader(
      store: store ?? _FakeStore(),
      transport: transport,
      fileUtils: fileUtils ?? _FakeFileUtils('utf-8'),
    );

void main() {
  test('resolves with an Attachment when the upload succeeds', () async {
    final attachment =
        await _uploader(transport: _SuccessfulTransport()).upload(_uploadRequest());

    expect(attachment.name, 'hello.txt');
    expect(attachment.size?.value, 42);
  });

  test('hands the staged file and request details to the transport unchanged',
      () async {
    // The uploader owns none of these values; anything it rewrites on the way
    // through would upload the right bytes to the wrong place, or drop the
    // caller's progress reporting.
    final store = _FakeStore()..fileContent = 'hello opfs';
    final transport = _SuccessfulTransport();
    final request = _uploadRequest();

    await _uploader(store: store, transport: transport).upload(request);

    final sent = transport.request!;
    expect(sent.file, same(store.lastFile));
    expect(sent.uploadUri, request.uploadUri);
    expect(sent.authHeader, request.authHeader);
    expect(sent.mimeType, request.mimeType);
    expect(sent.onUploadProgress, same(request.onUploadProgress));
  });

  test('detects the charset of a text/plain document from a prefix', () async {
    final fileUtils = _FakeFileUtils('ISO-8859-1');

    final attachment = await _uploader(
      store: _FakeStore()..fileContent = 'hello opfs',
      transport: _SuccessfulTransport(),
      fileUtils: fileUtils,
    ).upload(_uploadRequest());

    // Lowercased, the way `FileUploader` stores it.
    expect(attachment.charset, 'iso-8859-1');
    expect(fileUtils.sniffedByteCounts, ['hello opfs'.length]);
  });

  test('leaves the charset unset for a non-text document', () async {
    final fileUtils = _FakeFileUtils('ISO-8859-1');

    final attachment = await _uploader(
      store: _FakeStore()..fileContent = 'hello opfs',
      transport: _SuccessfulTransport(),
      fileUtils: fileUtils,
    ).upload(_uploadRequest(mimeType: 'application/pdf'));

    expect(attachment.charset, isNull);
    expect(fileUtils.sniffedByteCounts, isEmpty);
  });

  test('uploads without a charset when detection fails', () async {
    // A sniff failure is not worth losing the upload over: the server can
    // infer the encoding, so this ends the same way a non-text file does.
    final attachment = await _uploader(
      store: _FakeStore()..fileContent = 'hello opfs',
      transport: _SuccessfulTransport(),
      fileUtils: _ThrowingFileUtils(),
    ).upload(_uploadRequest());

    expect(attachment.charset, isNull);
    expect(attachment.name, 'hello.txt');
  });

  test('maps an upload transport failure to a DioException', () async {
    await expectLater(
      _uploader(transport: _FailingTransport()).upload(_uploadRequest()),
      // `unknown`, not `badResponse`: the transport failed before any server
      // answer, so blaming the response would point callers at the wrong half.
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.unknown)
          .having((e) => e.error, 'error', isA<StateError>())),
    );
  });

  test('maps an unparseable success response to a DioException', () async {
    // A 2xx whose JSON parsed but doesn't match the upload schema makes
    // `UploadResponse.fromJson` throw a `TypeError`, which no caller can
    // classify on its own.
    await expectLater(
      _uploader(transport: _MalformedBodyTransport()).upload(_uploadRequest()),
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.badResponse)),
    );
  });

  test('maps a failure to open the staged entry to a DioException', () async {
    // The entry can be gone by upload time — swept by another tab, or removed
    // when a transfer was cancelled — and `getFile` then rejects with a bare
    // browser error.
    final transport = _SuccessfulTransport();

    await expectLater(
      _uploader(store: _FailingGetFileStore(), transport: transport)
          .upload(_uploadRequest()),
      // A browser error off the OPFS read has no HTTP meaning, so it comes out
      // as `unknown` carrying the original failure.
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.unknown)
          .having((e) => e.error, 'error', isA<StateError>())),
    );
    expect(transport.uploadFileCalled, isFalse);
  });

  test('calling cancel aborts the in-flight upload', () async {
    final transport = _AbortableTransport();
    final cancelToken = CancelToken();

    final upload = _uploader(transport: transport)
        .upload(_uploadRequest(cancelToken: cancelToken));

    // Waits for the XHR to actually exist rather than for a fixed number of
    // microtasks, so this keeps exercising the whenCancel -> abort wiring —
    // and not the pre-XHR guard — however many awaits precede the upload.
    await transport.uploadFileStarted;
    cancelToken.cancel();

    // The same error a cancel before the XHR existed produces.
    await expectLater(
      upload,
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.cancel)),
    );
    expect(transport.aborted, isTrue);
  });

  test('does not abort an upload that already completed', () async {
    // `whenCancel` cannot be unsubscribed and the token outlives the transfer,
    // so a cancel arriving later must find nothing to abort — otherwise the
    // listener would poke an XHR belonging to a finished upload.
    final transport = _AbortableTransport(completeImmediately: true);
    final cancelToken = CancelToken();

    await _uploader(transport: transport)
        .upload(_uploadRequest(cancelToken: cancelToken));

    cancelToken.cancel();
    // Lets the `whenCancel` listener run before the assertion.
    await Future<void>.delayed(Duration.zero);

    expect(transport.aborted, isFalse);
  });

  test('sniffs at most 64KB of a large text document', () async {
    // Reading the document whole would hand back exactly the memory profile
    // this upload path exists to avoid.
    final fileUtils = _FakeFileUtils('utf-8');

    await _uploader(
      store: _FakeStore()..fileContent = 'x' * (128 * 1024),
      transport: _SuccessfulTransport(),
      fileUtils: fileUtils,
    ).upload(_uploadRequest());

    expect(fileUtils.sniffedByteCounts, [64 * 1024]);
  });

  test('does not create the XHR when cancelled while getFile is pending',
      () async {
    final store = _DeferredGetFileStore();
    final transport = _SuccessfulTransport();
    final cancelToken = CancelToken();

    final upload = _uploader(store: store, transport: transport)
        .upload(_uploadRequest(cancelToken: cancelToken));

    // getFile has started (and is pending) by the time this runs; cancel
    // here exercises the *second* guard, after getFile resolves, not the
    // pre-getFile one.
    await Future<void>.delayed(Duration.zero);
    cancelToken.cancel();
    store.completeGetFile();

    await expectLater(
      upload,
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.cancel)),
    );
    expect(transport.uploadFileCalled, isFalse);
  });
}

/// The file is never read past its prefix, only handed to `uploadFile`, so
/// every case stubs `getFile` the same way and varies only the upload half.
class _FakeStore extends OpfsFileOps {
  /// Only the charset cases care what is in the file; everything else uploads
  /// an empty one.
  String fileContent = '';

  /// The snapshot handed to the uploader, so a test can assert the very same
  /// file reached the transport.
  web.File? lastFile;

  @override
  Future<web.File> getFile(OpfsFileHandle fileHandle) async =>
      lastFile = _fakeFile(fileContent);
}

class _FailingGetFileStore extends _FakeStore {
  @override
  Future<web.File> getFile(OpfsFileHandle fileHandle) async {
    throw StateError('the staged entry is gone');
  }
}

class _DeferredGetFileStore extends _FakeStore {
  final _getFileCompleter = Completer<web.File>();

  void completeGetFile() => _getFileCompleter.complete(_fakeFile());

  @override
  Future<web.File> getFile(OpfsFileHandle fileHandle) =>
      _getFileCompleter.future;
}

class _ThrowingFileUtils extends FileUtils {
  @override
  Future<String> getCharsetFromBytes(Uint8List bytes) async {
    throw StateError('charset detection unavailable');
  }
}

class _SuccessfulTransport implements DriveUploadTransport {
  bool uploadFileCalled = false;

  /// What the uploader actually sent, for the case asserting it forwards the
  /// request untouched.
  XhrUploadFileRequest? request;

  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    uploadFileCalled = true;
    this.request = request;
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

class _FailingTransport implements DriveUploadTransport {
  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    return XhrUploadHandle(
      response: Future.error(StateError('upload failed')),
      abort: () {},
    );
  }
}

/// A 2xx body that parsed as JSON but carries none of the fields
/// `UploadResponse` requires.
class _MalformedBodyTransport implements DriveUploadTransport {
  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    return XhrUploadHandle(
      response: Future.value(<String, dynamic>{'unexpected': 'shape'}),
      abort: () {},
    );
  }
}

class _AbortableTransport implements DriveUploadTransport {
  _AbortableTransport({this.completeImmediately = false});

  /// Ends the upload as soon as it starts, for the case where the cancel
  /// arrives after the transfer is already over.
  final bool completeImmediately;

  bool aborted = false;
  final _uploadFileStarted = Completer<void>();

  /// Resolves once the XHR exists, i.e. once cancelling can only go through
  /// the abort wiring.
  Future<void> get uploadFileStarted => _uploadFileStarted.future;

  @override
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    if (!_uploadFileStarted.isCompleted) _uploadFileStarted.complete();
    final completer = Completer<Map<String, dynamic>>();
    if (completeImmediately) {
      completer.complete({
        'accountId': 'account-1',
        'blobId': 'blob-1',
        'type': 'text/plain',
        'size': 42,
      });
    }
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
