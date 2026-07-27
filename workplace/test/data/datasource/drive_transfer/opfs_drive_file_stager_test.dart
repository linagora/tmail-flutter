@TestOn('chrome')
library;

import 'dart:async';
import 'dart:js_interop';
// `setProperty` — building the ReadableStream underlying source object.
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_fetch_streaming.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

void main() {
  test('stages a fetched file into OPFS and reports cumulative progress',
      () async {
    const content = 'hello opfs world';
    final dataUrl = Uri.dataFromString(content, mimeType: 'text/plain');

    final doc = DriveDocument(
      id: 'doc-opfs-1',
      name: 'hello.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: dataUrl,
    );

    final progress = <int>[];
    final staged = await OpfsDriveFileStager().stage(
      doc: doc,
      onDownloadProgress: (received, total) => progress.add(received),
      cancelToken: CancelToken(),
    );

    expect(staged, isA<OpfsStagedFile>());
    final opfsStaged = staged;
    expect(opfsStaged.fileSize, content.length);
    expect(opfsStaged.fileName, doc.name);
    expect(progress, isNotEmpty);
    expect(progress.last, content.length);
    // Progress is cumulative, so it never decreases between chunks.
    expect(progress, orderedEquals(List.of(progress)..sort()));

    // The staged entry must hold the fetched bytes, not just the right size.
    final stagedFile =
        await OpfsJsBindings.instance.getFile(opfsStaged.fileHandle);
    expect((await stagedFile.text().toDart).toDart, content);

    // dispose() must remove the OPFS temp entry on every exit path; a
    // real `FileSystemDirectoryHandle.removeEntry` call throwing would
    // surface here.
    await opfsStaged.dispose();
  });

  test('rethrows when the download fails before the temp entry is created',
      () async {
    final doc = DriveDocument(
      id: 'doc-opfs-2',
      name: 'missing.bin',
      size: 0,
      mimeType: 'application/octet-stream',
      downloadLink: Uri.parse('https://drive.example/missing.bin'),
    );

    await expectLater(
      OpfsDriveFileStager(bindings: _FailingFetchOpfsJsBindings()).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('removes the OPFS temp entry when the transfer fails mid-stream',
      () async {
    final bindings = _FailingReadOpfsJsBindings();
    const content = 'hello opfs world';

    final doc = DriveDocument(
      id: 'doc-opfs-3',
      name: 'mid-stream.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
    );

    await expectLater(
      OpfsDriveFileStager(bindings: bindings).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<StateError>()),
    );

    // The temp entry was created before the failure, so cleanup must remove it.
    expect(bindings.removeTempFileCount, 1);
  });

  test('removes the OPFS temp entry even when aborting the writable fails',
      () async {
    final bindings = _FailingAbortOpfsJsBindings();
    const content = 'hello opfs world';

    final doc = DriveDocument(
      id: 'doc-opfs-abort',
      name: 'failed-abort.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
    );

    await expectLater(
      OpfsDriveFileStager(bindings: bindings).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<StateError>()),
    );

    // The writable is still open, which locks the entry against `removeEntry`
    // — cleanup has to close it before the removal can land.
    expect(bindings.createdNames, hasLength(1));
    expect(await _opfsEntryExists(bindings.createdNames.single), isFalse);
  });

  test('stages a document whose name contains a path separator', () async {
    const content = 'nested';
    final doc = DriveDocument(
      id: 'doc-opfs-4',
      name: '2024/report.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
    );

    final staged = await OpfsDriveFileStager().stage(
      doc: doc,
      onDownloadProgress: (_, __) {},
      cancelToken: CancelToken(),
    );

    expect(staged.fileSize, content.length);
    expect(staged.fileName, doc.name);
    await staged.dispose();
  });

  test('throws DriveDownloadNullAttachmentException when downloadLink is null',
      () async {
    const doc = DriveDocument(
      id: 'doc-opfs-5',
      name: 'no-link.txt',
      size: 0,
      mimeType: 'text/plain',
    );

    await expectLater(
      OpfsDriveFileStager().stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DriveDownloadNullAttachmentException>()),
    );
  });

  test('throws DriveDownloadInsecureLinkException in release mode for http',
      () async {
    final doc = DriveDocument(
      id: 'doc-opfs-6',
      name: 'insecure.txt',
      size: 0,
      mimeType: 'text/plain',
      downloadLink: Uri.parse('http://drive.example/file'),
    );

    await expectLater(
      OpfsDriveFileStager(isReleaseMode: true).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DriveDownloadInsecureLinkException>()),
    );
  });

  test('fails the transfer when cancelled while a chunk read is in flight',
      () async {
    final bindings = _ControllableStreamBindings(contentLength: 16);
    final cancelToken = CancelToken();

    final doc = DriveDocument(
      id: 'doc-opfs-7',
      name: 'cancelled-mid-read.txt',
      size: 16,
      mimeType: 'text/plain',
      downloadLink: Uri.parse('https://drive.example/cancelled-mid-read.txt'),
    );

    final staging = OpfsDriveFileStager(bindings: bindings).stage(
      doc: doc,
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );

    // Cancel only once the second `read()` is actually in flight, so this
    // exercises cancellation arriving mid-read rather than between iterations.
    await bindings.secondReadStarted;
    cancelToken.cancel();

    await expectLater(staging, throwsA(isA<DioException>()));
  });

  test('stops reading immediately when cancelled between chunk reads',
      () async {
    final cancelToken = CancelToken();
    final bindings = _ControllableStreamBindings(
      contentLength: 16,
      onFirstChunkWritten: () => cancelToken.cancel(),
    );

    final doc = DriveDocument(
      id: 'doc-opfs-7b',
      name: 'cancelled-between-reads.txt',
      size: 16,
      mimeType: 'text/plain',
      downloadLink:
          Uri.parse('https://drive.example/cancelled-between-reads.txt'),
    );

    final staging = OpfsDriveFileStager(bindings: bindings).stage(
      doc: doc,
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );

    // The cancel fires from inside `writeChunk` (see [onFirstChunkWritten]),
    // so it lands *between* iterations — the case the loop-top guard exists
    // for, as opposed to the mid-read case covered above.
    await expectLater(staging, throwsA(isA<DioException>()));
    // The guard has to bail out before the next `read()`: `cancelReader` is
    // async, so without it the loop would issue a second read and keep going
    // until the cancellation propagated through the JS reader.
    expect(bindings.readCount, 1);
  });

  test('fails the transfer when the body ends short of content-length',
      () async {
    final bindings = _ControllableStreamBindings(
      contentLength: 16,
      closeAfterFirstChunk: true,
    );

    final doc = DriveDocument(
      id: 'doc-opfs-8',
      name: 'truncated.txt',
      size: 16,
      mimeType: 'text/plain',
      downloadLink: Uri.parse('https://drive.example/truncated.txt'),
    );

    await expectLater(
      OpfsDriveFileStager(bindings: bindings).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DriveDownloadIncompleteException>()),
    );
  });

  group('orphaned temp entries', () {
    test('every transfer takes its own OPFS entry, so they stack up', () async {
      const content = 'orphan me';
      final bindings = _NameRecordingBindings();
      addTearDown(() => _removeEntries(bindings.createdNames));

      final doc = DriveDocument(
        id: 'doc-opfs-orphan',
        name: 'orphan.txt',
        size: content.length,
        mimeType: 'text/plain',
        downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
      );

      // Three transfers of one document, none disposed — the shape of a tab
      // closed or crashed after staging.
      for (var i = 0; i < 3; i++) {
        await OpfsDriveFileStager(bindings: bindings).stage(
          doc: doc,
          onDownloadProgress: (_, __) {},
          cancelToken: CancelToken(),
        );
      }

      // Distinct names, so they accumulate rather than overwrite each other.
      expect(bindings.createdNames.toSet(), hasLength(3));
      for (final name in bindings.createdNames) {
        expect(await _opfsEntryExists(name), isTrue,
            reason: '$name should still be in OPFS');
      }
    });

    test('sweepStaleTempFiles reclaims them', () async {
      const content = 'sweep me';
      final bindings = _NameRecordingBindings();
      addTearDown(() => _removeEntries(bindings.createdNames));

      final doc = DriveDocument(
        id: 'doc-opfs-sweep',
        name: 'sweep.txt',
        size: content.length,
        mimeType: 'text/plain',
        downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
      );

      await OpfsDriveFileStager(bindings: bindings).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );
      final orphan = bindings.createdNames.single;

      // No staging prefix, so it stands in for whatever else the origin keeps
      // in the OPFS root — the sweep must not touch it.
      const bystander = 'unrelated-origin-data.txt';
      await bindings.createTempFile(bystander);
      addTearDown(() => _removeEntries([bystander]));

      // Zero age: everything staged before this call is past the cutoff.
      await bindings.sweepStaleTempFiles(olderThan: Duration.zero);

      expect(await _opfsEntryExists(orphan), isFalse);
      expect(await _opfsEntryExists(bystander), isTrue);
    });

    test('sweepStaleTempFiles spares entries younger than the cutoff',
        () async {
      const content = 'still in flight';
      final bindings = _NameRecordingBindings();
      addTearDown(() => _removeEntries(bindings.createdNames));

      final doc = DriveDocument(
        id: 'doc-opfs-inflight',
        name: 'inflight.txt',
        size: content.length,
        mimeType: 'text/plain',
        downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
      );

      await OpfsDriveFileStager(bindings: bindings).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      // A second tab mid-transfer looks exactly like this entry, and must
      // survive another tab's sweep.
      await bindings.sweepStaleTempFiles();

      expect(await _opfsEntryExists(bindings.createdNames.single), isTrue);
    });
  });

  group('OpfsDriveTransferStrategy', () {
    test(
        'transfer() stages, uploads the staged handle, then removes the entry',
        () async {
      final handle = await _createOpfsHandle('strategy-upload.bin');
      addTearDown(() => _removeEntries(['strategy-upload.bin']));
      final removedHandles = <OpfsFileHandle>[];
      final stager = _RecordingDriveFileStager(OpfsStagedFile(
        fileHandle: handle,
        removeEntry: (removed) async => removedHandles.add(removed),
        fileName: 'file.bin',
        fileSize: 3,
        mimeType: 'image/png',
      ));
      final uploader = _RecordingOpfsDriveFileUploader();
      final strategy =
          OpfsDriveTransferStrategy(stager: stager, uploader: uploader);
      final doc = DriveDocument(
        id: 'doc-1',
        name: 'file.bin',
        size: 3,
        mimeType: 'application/octet-stream',
        downloadLink: Uri.parse('https://drive.example/file'),
      );
      final uploadUri = Uri.parse('https://jmap.example/upload');
      final cancelToken = CancelToken();
      void onDownloadProgress(int r, int t) {}
      void onUploadProgress(int s, int t) {}

      final attachment = await strategy.transfer(DriveTransferRequest(
        doc: doc,
        uploadUri: uploadUri,
        authHeader: 'Bearer token',
        onDownloadProgress: onDownloadProgress,
        onUploadProgress: onUploadProgress,
        cancelToken: cancelToken,
      ));

      expect(stager.doc, same(doc));
      expect(stager.onDownloadProgress, same(onDownloadProgress));
      expect(stager.cancelToken, same(cancelToken));

      expect(attachment, same(uploader.result));
      final request = uploader.request!;
      expect(request.fileHandle, same(handle));
      expect(request.fileName, 'file.bin');
      expect(request.mimeType, 'image/png');
      expect(request.uploadUri, uploadUri);
      expect(request.authHeader, 'Bearer token');
      expect(request.onUploadProgress, same(onUploadProgress));
      expect(request.cancelToken, same(cancelToken));

      // The OPFS temp entry is reclaimed once the upload has returned.
      expect(removedHandles, [same(handle)]);
    });
  });
}

/// Resolved from a fresh OPFS root, so this answers whether the bytes are on
/// disk, not whether some handle still points at them.
Future<bool> _opfsEntryExists(String name) async {
  final root = await web.window.navigator.storage.getDirectory().toDart;
  try {
    await root.getFileHandle(name).toDart;
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _removeEntries(Iterable<String> names) async {
  final root = await web.window.navigator.storage.getDirectory().toDart;
  for (final name in names) {
    try {
      await root.removeEntry(name).toDart;
    } catch (_) {
      // Already gone; nothing to undo.
    }
  }
}

/// Captures the generated temp-entry names, otherwise private to the stager,
/// so a test can look them up after the fact.
class _NameRecordingBindings extends OpfsJsBindings {
  final createdNames = <String>[];

  @override
  Future<web.FileSystemFileHandle> createTempFile(String fileName) {
    createdNames.add(fileName);
    return super.createTempFile(fileName);
  }
}

Future<web.FileSystemFileHandle> _createOpfsHandle(String fileName) async {
  final dir = await web.window.navigator.storage.getDirectory().toDart;
  return dir
      .getFileHandle(fileName, web.FileSystemGetFileOptions(create: true))
      .toDart;
}

class _RecordingDriveFileStager implements DriveFileStager<OpfsStagedFile> {
  _RecordingDriveFileStager(this.result);

  final OpfsStagedFile result;

  DriveDocument? doc;
  OnFileProcessedProgress? onDownloadProgress;
  CancelToken? cancelToken;

  @override
  Future<OpfsStagedFile> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    this.doc = doc;
    this.onDownloadProgress = onDownloadProgress;
    this.cancelToken = cancelToken;
    return result;
  }
}

class _RecordingOpfsDriveFileUploader implements OpfsDriveFileUploader {
  final Attachment result = Attachment(name: 'file.bin');

  OpfsUploadRequest? request;

  @override
  Future<Attachment> upload(OpfsUploadRequest request) async {
    this.request = request;
    return result;
  }
}

/// Creates the OPFS entry for real, then fails on the first chunk read — the
/// only way to reach the cleanup path that removes an already-created entry.
class _FailingReadOpfsJsBindings extends OpfsJsBindings {
  int removeTempFileCount = 0;

  @override
  Future<Uint8List?> readChunk(web.ReadableStreamDefaultReader reader) async {
    throw StateError('read failed');
  }

  @override
  Future<void> removeTempFile(String fileName) async {
    await super.removeTempFile(fileName);
    removeTempFileCount++;
  }
}

/// Creates the OPFS entry for real, fails on the first chunk read, and then
/// fails the abort that cleanup relies on — leaving the writable genuinely
/// open, so the entry is locked against `removeEntry` unless cleanup closes it.
class _FailingAbortOpfsJsBindings extends OpfsJsBindings {
  final createdNames = <String>[];

  @override
  Future<web.FileSystemFileHandle> createTempFile(String fileName) {
    createdNames.add(fileName);
    return super.createTempFile(fileName);
  }

  @override
  Future<Uint8List?> readChunk(web.ReadableStreamDefaultReader reader) async {
    throw StateError('read failed');
  }

  @override
  Future<void> abortWritable(web.FileSystemWritableFileStream stream) async {
    throw StateError('abort failed');
  }
}

/// Fails before any OPFS entry is created — `stage` calls `fetchStream`
/// first, so this exercises the pre-staging failure path deterministically,
/// without depending on browser networking.
class _FailingFetchOpfsJsBindings extends OpfsJsBindings {
  @override
  Future<OpfsFetchStream> fetchStream(Uri url, {Future<void>? cancelSignal}) {
    throw StateError('fetch failed');
  }
}

/// Serves the body from a real `ReadableStream` that emits one 3-byte chunk
/// and then either stalls or closes. Only the *source* of the bytes is
/// substituted: `read`, `cancel`, and every OPFS write below them run
/// against the browser, so the streams semantics under test are Chrome's,
/// not the fake's.
///
/// [cancelSignal] is deliberately ignored so the fetch-abort path can't race
/// the reader-cancel path — these tests isolate the latter.
class _ControllableStreamBindings extends OpfsJsBindings {
  _ControllableStreamBindings({
    required this.contentLength,
    this.closeAfterFirstChunk = false,
    this.onFirstChunkWritten,
  });

  final int contentLength;
  final bool closeAfterFirstChunk;

  /// Called synchronously at the end of the first `writeChunk`, i.e. before
  /// the stager's `await` on it resumes. Cancelling from here is the only way
  /// to land *between* iterations: completing a future the test awaits is not
  /// enough, since the stager wins that race and issues its next `read()`.
  final void Function()? onFirstChunkWritten;

  final _firstChunkWritten = Completer<void>();
  final _secondReadStarted = Completer<void>();
  var _readCount = 0;

  /// Resolves once the first chunk has been written to the OPFS temp file.
  Future<void> get firstChunkWritten => _firstChunkWritten.future;

  /// How many `read()` calls the loop has issued.
  int get readCount => _readCount;

  /// Resolves once the read loop is parked inside its second `read()`.
  /// [firstChunkWritten] is not a substitute: it completes before the stager
  /// resumes, so waiting on it lands *between* iterations.
  Future<void> get secondReadStarted => _secondReadStarted.future;

  /// Deliberately not `async`: the synchronous body starts `super.readChunk`
  /// — which itself runs as far as its `await reader.read()` — before the
  /// `complete()` microtask lets the waiting test resume. That ordering is
  /// what makes the read genuinely in flight at cancellation time.
  @override
  Future<Uint8List?> readChunk(web.ReadableStreamDefaultReader reader) {
    if (++_readCount == 2 && !_secondReadStarted.isCompleted) {
      _secondReadStarted.complete();
    }
    return super.readChunk(reader);
  }

  @override
  Future<OpfsFetchStream> fetchStream(Uri url,
      {Future<void>? cancelSignal}) async {
    final source = JSObject();
    source.setProperty(
      'start'.toJS,
      ((web.ReadableStreamDefaultController controller) {
        controller.enqueue(Uint8List.fromList([1, 2, 3]).toJS);
        if (closeAfterFirstChunk) controller.close();
      }).toJS,
    );
    final stream = web.ReadableStream(source);
    return OpfsFetchStream(
      reader: stream.getReader() as web.ReadableStreamDefaultReader,
      contentLength: contentLength,
    );
  }

  @override
  Future<void> writeChunk(
      web.FileSystemWritableFileStream stream, Uint8List chunk) async {
    await super.writeChunk(stream, chunk);
    if (!_firstChunkWritten.isCompleted) {
      _firstChunkWritten.complete();
      onFirstChunkWritten?.call();
    }
  }
}
