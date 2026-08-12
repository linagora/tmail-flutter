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
import 'package:workplace/data/datasource/drive_transfer/drive_download_source.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_fetch_download.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
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
    final store = _NameRecordingStore();
    addTearDown(() => _removeEntries(store.createdNames));
    final staged = await OpfsDriveFileStager(store: store).stage(
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
    final stagedFile = await OpfsFileOps().getFile(opfsStaged.fileHandle);
    expect((await stagedFile.text().toDart).toDart, content);

    // dispose() must remove the OPFS temp entry on every exit path; asserted
    // against a fresh OPFS root, so this answers whether the bytes are gone
    // rather than whether dispose() merely returned.
    await opfsStaged.dispose();
    expect(await _opfsEntryExists(store.createdNames.single), isFalse);
  });

  test('stages the whole file even when the progress callback throws',
      () async {
    // The callback is the caller's; a throw from it must not unwind the pump
    // and fail a transfer whose bytes are arriving fine.
    const content = 'progress callbacks are not the transfer';
    final doc = DriveDocument(
      id: 'doc-opfs-throwing-progress',
      name: 'hello.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
    );

    final store = _NameRecordingStore();
    addTearDown(() => _removeEntries(store.createdNames));
    final staged = await OpfsDriveFileStager(store: store).stage(
      doc: doc,
      onDownloadProgress: (_, __) => throw StateError('progress consumer blew up'),
      cancelToken: CancelToken(),
    );

    expect(staged.fileSize, content.length);
    final stagedFile = await OpfsFileOps().getFile(staged.fileHandle);
    expect((await stagedFile.text().toDart).toDart, content);

    await staged.dispose();
  });

  test('maps a download failure before the temp entry exists to a DioException',
      () async {
    final doc = DriveDocument(
      id: 'doc-opfs-2',
      name: 'missing.bin',
      size: 0,
      mimeType: 'application/octet-stream',
      downloadLink: Uri.parse('https://drive.example/missing.bin'),
    );

    await expectLater(
      OpfsDriveFileStager(download: _FailingOpenDownload()).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      // Shaped on the way out, with the original failure preserved, so callers
      // never have to classify a raw browser error.
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.unknown)
          .having((e) => e.error, 'error', isA<StateError>())),
    );
  });

  test('maps a raw OPFS write failure to a DioException', () async {
    // `writeChunk` is the step most likely to fail for a reason the user can
    // act on — a full disk raises `QuotaExceededError` — and nothing in the
    // pump guards it, so this is what proves the single outer mapping covers
    // the storage half too.
    const content = 'hello opfs world';
    final doc = DriveDocument(
      id: 'doc-opfs-2b',
      name: 'write-fails.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
    );

    await expectLater(
      OpfsDriveFileStager(store: _FailingWriteStore()).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.unknown)
          .having((e) => e.error, 'error', isA<StateError>())),
    );
  });

  test('removes the OPFS temp entry when the transfer fails mid-stream',
      () async {
    final store = _CountingRemoveStore();
    const content = 'hello opfs world';

    final doc = DriveDocument(
      id: 'doc-opfs-3',
      name: 'mid-stream.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
    );

    await expectLater(
      OpfsDriveFileStager(download: _FailingReadDownload(), store: store).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DioException>()),
    );

    // The temp entry was created before the failure, so cleanup must remove it.
    expect(store.removeTempFileCount, 1);
  });

  test('removes the OPFS temp entry even when aborting the writable fails',
      () async {
    final store = _FailingAbortStore();
    const content = 'hello opfs world';

    final doc = DriveDocument(
      id: 'doc-opfs-abort',
      name: 'failed-abort.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
    );

    await expectLater(
      OpfsDriveFileStager(download: _FailingReadDownload(), store: store).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DioException>()),
    );

    // The writable is still open, which locks the entry against `removeEntry`
    // — cleanup has to close it before the removal can land.
    expect(store.createdNames, hasLength(1));
    expect(await _opfsEntryExists(store.createdNames.single), isFalse);
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

  test('reports a cancel when cancelled while a chunk read is in flight',
      () async {
    final download = _ScriptedDownload(contentLength: 16);
    final cancelToken = CancelToken();

    final doc = DriveDocument(
      id: 'doc-opfs-7',
      name: 'cancelled-mid-read.txt',
      size: 16,
      mimeType: 'text/plain',
      downloadLink: Uri.parse('https://drive.example/cancelled-mid-read.txt'),
    );

    final staging = OpfsDriveFileStager(download: download).stage(
      doc: doc,
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );

    // Cancel only once the second `read()` is actually in flight, so this
    // exercises cancellation arriving mid-read rather than between iterations.
    await download.secondReadStarted;
    cancelToken.cancel();

    // The abort reaches the loop as a browser error on the read; only the
    // token identifies it, and it still has to come out as a cancellation
    // rather than as whatever the browser threw.
    await expectLater(
      staging,
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.cancel)),
    );
  });

  test('reports a cancel when cancelled between chunk reads', () async {
    final cancelToken = CancelToken();
    final store = _WriteHookStore(onFirstChunkWritten: () => cancelToken.cancel());
    final download = _ScriptedDownload(contentLength: 16);

    final doc = DriveDocument(
      id: 'doc-opfs-7b',
      name: 'cancelled-between-reads.txt',
      size: 16,
      mimeType: 'text/plain',
      downloadLink:
          Uri.parse('https://drive.example/cancelled-between-reads.txt'),
    );

    final staging =
        OpfsDriveFileStager(download: download, store: store).stage(
      doc: doc,
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );

    // The cancel fires from inside `writeChunk` (see [onFirstChunkWritten]),
    // so it lands *between* iterations rather than mid-read. Cancellation runs
    // through one mechanism now — the abort signal errors the body stream — so
    // the next read rejects and the outcome is the same either way.
    await expectLater(
      staging,
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.cancel)),
    );
  });

  test('reports a connection error when the body fails mid-stream', () async {
    // The same rejection with no cancellation behind it — a dropped
    // connection — has to surface as a DioException too, not as the raw
    // browser error.
    final download = _ScriptedDownload(
      contentLength: 16,
      errorStreamOnSecondRead: true,
    );

    final doc = DriveDocument(
      id: 'doc-opfs-7d',
      name: 'dropped-mid-read.txt',
      size: 16,
      mimeType: 'text/plain',
      downloadLink: Uri.parse('https://drive.example/dropped-mid-read.txt'),
    );

    await expectLater(
      OpfsDriveFileStager(download: download).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.connectionError)),
    );
  });

  test('fails the transfer when the body ends short of content-length',
      () async {
    final download = _ScriptedDownload(
      contentLength: 16,
      closeAfterChunks: true,
    );

    final doc = DriveDocument(
      id: 'doc-opfs-8',
      name: 'truncated.txt',
      size: 16,
      mimeType: 'text/plain',
      downloadLink: Uri.parse('https://drive.example/truncated.txt'),
    );

    await expectLater(
      OpfsDriveFileStager(download: download).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      // Passed through rather than flattened into a DioException: it carries
      // the received/expected counts callers report.
      throwsA(isA<DriveDownloadIncompleteException>()
          .having((e) => e.received, 'received', 3)
          .having((e) => e.expected, 'expected', 16)),
    );
  });

  group('chunked download', () {
    // Three chunks of different sizes: the loop has to iterate, and a single
    // buffered write would show up as one write of nine bytes.
    const chunks = [
      [1, 2, 3],
      [4, 5],
      [6, 7, 8, 9]
    ];
    const totalBytes = 9;

    DriveDocument chunkedDoc(String id) => DriveDocument(
          id: id,
          name: 'chunked.bin',
          size: totalBytes,
          mimeType: 'application/octet-stream',
          downloadLink: Uri.parse('https://drive.example/chunked.bin'),
        );

    _ScriptedDownload chunkedDownload() => _ScriptedDownload(
          contentLength: totalBytes,
          chunks: chunks,
          closeAfterChunks: true,
        );

    test('accumulates progress across chunks', () async {
      final progress = <int>[];
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      await OpfsDriveFileStager(download: chunkedDownload(), store: store).stage(
        doc: chunkedDoc('doc-opfs-chunked-progress'),
        onDownloadProgress: (received, _) => progress.add(received),
        cancelToken: CancelToken(),
      );

      // A running total, not the size of each chunk on its own.
      expect(progress, [3, 5, 9]);
    });

    test('writes each chunk as it arrives rather than buffering the body',
        () async {
      final store = _ChunkRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      await OpfsDriveFileStager(download: chunkedDownload(), store: store).stage(
        doc: chunkedDoc('doc-opfs-chunked-writes'),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      // One write per chunk: materialising the body first — the memory profile
      // this stager exists to avoid — would be a single 9-byte write.
      expect(store.writtenChunkLengths, [3, 2, 4]);
    });

    test('stages the concatenation of every chunk, in order', () async {
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      final staged =
          await OpfsDriveFileStager(download: chunkedDownload(), store: store)
              .stage(
        doc: chunkedDoc('doc-opfs-chunked-bytes'),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      expect(await _stagedBytes(staged), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      await staged.dispose();
    });

    test('returns the total received byte count as the staged file size',
        () async {
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      final staged =
          await OpfsDriveFileStager(download: chunkedDownload(), store: store)
              .stage(
        doc: chunkedDoc('doc-opfs-chunked-size'),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      // What arrived, not what the document claimed or the header declared.
      expect(staged.fileSize, totalBytes);
      await staged.dispose();
    });
  });

  group('content-length', () {
    test('succeeds when the body overruns content-length', () async {
      // What a `content-encoding` response looks like: the header declares the
      // compressed size while `fetch` hands over the decompressed body.
      final download = _ScriptedDownload(
        contentLength: 2,
        chunks: const [
          [1, 2, 3],
          [4, 5, 6]
        ],
        closeAfterChunks: true,
      );
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      final staged =
          await OpfsDriveFileStager(download: download, store: store).stage(
        doc: DriveDocument(
          id: 'doc-opfs-overrun',
          name: 'compressed.bin',
          size: 2,
          mimeType: 'application/octet-stream',
          downloadLink: Uri.parse('https://drive.example/compressed.bin'),
        ),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      expect(staged.fileSize, 6);
      await staged.dispose();
    });

    test('skips the completeness check when the response declares no length',
        () async {
      // -1 is what an absent (or CORS-hidden) content-length parses to, and
      // there is then nothing to compare a short body against.
      final download = _ScriptedDownload(contentLength: -1, closeAfterChunks: true);
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      final staged =
          await OpfsDriveFileStager(download: download, store: store).stage(
        doc: DriveDocument(
          id: 'doc-opfs-no-length',
          name: 'chunked-response.bin',
          size: 0,
          mimeType: 'application/octet-stream',
          downloadLink: Uri.parse('https://drive.example/chunked-response.bin'),
        ),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      expect(staged.fileSize, 3);
      await staged.dispose();
    });

    test('removes the truncated temp entry when the body ends short', () async {
      final download = _ScriptedDownload(contentLength: 16, closeAfterChunks: true);
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      await expectLater(
        OpfsDriveFileStager(download: download, store: store).stage(
          doc: DriveDocument(
            id: 'doc-opfs-truncated-cleanup',
            name: 'truncated.bin',
            size: 16,
            mimeType: 'application/octet-stream',
            downloadLink: Uri.parse('https://drive.example/truncated.bin'),
          ),
          onDownloadProgress: (_, __) {},
          cancelToken: CancelToken(),
        ),
        throwsA(isA<DriveDownloadIncompleteException>()),
      );

      // The partial bytes were written before the check failed, so the entry
      // exists and cleanup has to reclaim it — nothing else ever will.
      expect(store.createdNames, hasLength(1));
      expect(await _opfsEntryExists(store.createdNames.single), isFalse);
    });
  });

  group('orphaned temp entries', () {
    test('every transfer takes its own OPFS entry, so they stack up', () async {
      const content = 'orphan me';
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

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
        await OpfsDriveFileStager(store: store).stage(
          doc: doc,
          onDownloadProgress: (_, __) {},
          cancelToken: CancelToken(),
        );
      }

      // Distinct names, so they accumulate rather than overwrite each other.
      expect(store.createdNames.toSet(), hasLength(3));
      for (final name in store.createdNames) {
        expect(await _opfsEntryExists(name), isTrue,
            reason: '$name should still be in OPFS');
      }
    });

    test('sweepStaleTempFiles reclaims them', () async {
      const content = 'sweep me';
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      final doc = DriveDocument(
        id: 'doc-opfs-sweep',
        name: 'sweep.txt',
        size: content.length,
        mimeType: 'text/plain',
        downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
      );

      await OpfsDriveFileStager(store: store).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );
      final orphan = store.createdNames.single;

      // No staging prefix, so it stands in for whatever else the origin keeps
      // in the OPFS root — the sweep must not touch it.
      const bystander = 'unrelated-origin-data.txt';
      await store.createTempFile(bystander);
      addTearDown(() => _removeEntries([bystander]));

      // Zero age: everything staged before this call is past the cutoff.
      await store.sweepStaleTempFiles(olderThan: Duration.zero);

      expect(await _opfsEntryExists(orphan), isFalse);
      expect(await _opfsEntryExists(bystander), isTrue);
    });

    test('sweepStaleTempFiles spares entries younger than the cutoff',
        () async {
      const content = 'still in flight';
      final store = _NameRecordingStore();
      addTearDown(() => _removeEntries(store.createdNames));

      final doc = DriveDocument(
        id: 'doc-opfs-inflight',
        name: 'inflight.txt',
        size: content.length,
        mimeType: 'text/plain',
        downloadLink: Uri.dataFromString(content, mimeType: 'text/plain'),
      );

      await OpfsDriveFileStager(store: store).stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      // A second tab mid-transfer looks exactly like this entry, and must
      // survive another tab's sweep.
      await store.sweepStaleTempFiles();

      expect(await _opfsEntryExists(store.createdNames.single), isTrue);
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

/// The bytes actually on disk, read back through the same store the uploader
/// would use.
Future<Uint8List> _stagedBytes(OpfsStagedFile staged) async {
  final file = await OpfsFileOps().getFile(staged.fileHandle);
  final buffer = await file.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
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
class _NameRecordingStore extends OpfsFileOps {
  final createdNames = <String>[];

  @override
  Future<web.FileSystemFileHandle> createTempFile(String fileName) {
    createdNames.add(fileName);
    return super.createTempFile(fileName);
  }
}

/// Records the size of every chunk handed to OPFS, so a test can tell a
/// chunk-at-a-time pump from one that buffered the body and wrote it once.
class _ChunkRecordingStore extends _NameRecordingStore {
  final writtenChunkLengths = <int>[];

  @override
  Future<void> writeChunk(
      web.FileSystemWritableFileStream stream, Uint8List chunk) async {
    await super.writeChunk(stream, chunk);
    writtenChunkLengths.add(chunk.length);
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

/// Fails on the first chunk read, so the OPFS entry is created for real before
/// the failure — the only way to reach the cleanup path that removes an
/// already-created entry.
class _FailingReadDownload extends OpfsFetchDownload {
  @override
  Future<Uint8List?> readChunk(web.ReadableStreamDefaultReader reader) async {
    throw StateError('read failed');
  }
}

/// Fails before any OPFS entry is created — `stage` calls `openDownload`
/// first, so this exercises the pre-staging failure path deterministically,
/// without depending on browser networking.
class _FailingOpenDownload extends OpfsFetchDownload {
  @override
  Future<FetchDownloadHandle> openDownload(Uri url, {Future<void>? cancelSignal}) {
    throw StateError('fetch failed');
  }
}

/// Counts the cleanup removal, so a test can assert the entry was reclaimed
/// rather than merely that `stage` threw.
class _CountingRemoveStore extends OpfsFileOps {
  int removeTempFileCount = 0;

  @override
  Future<void> removeTempFile(String fileName) async {
    await super.removeTempFile(fileName);
    removeTempFileCount++;
  }
}

/// Fails the abort cleanup relies on, leaving the writable genuinely open —
/// so the entry is locked against `removeEntry` unless cleanup closes it.
class _FailingAbortStore extends OpfsFileOps {
  final createdNames = <String>[];

  @override
  Future<web.FileSystemFileHandle> createTempFile(String fileName) {
    createdNames.add(fileName);
    return super.createTempFile(fileName);
  }

  @override
  Future<void> abortWritable(web.FileSystemWritableFileStream stream) async {
    throw StateError('abort failed');
  }
}

/// Stands in for a full disk: the storage half of the pipeline rejecting with
/// something that is not Dio-shaped.
class _FailingWriteStore extends OpfsFileOps {
  @override
  Future<void> writeChunk(
      web.FileSystemWritableFileStream stream, Uint8List chunk) async {
    throw StateError('write failed');
  }
}

/// Runs [onFirstChunkWritten] synchronously at the end of the first
/// `writeChunk`, i.e. before the stager's `await` on it resumes. Cancelling
/// from there is the only way to land *between* iterations: completing a
/// future the test awaits is not enough, since the stager wins that race and
/// issues its next `read()`.
class _WriteHookStore extends OpfsFileOps {
  _WriteHookStore({required this.onFirstChunkWritten});

  final void Function() onFirstChunkWritten;
  var _fired = false;

  @override
  Future<void> writeChunk(
      web.FileSystemWritableFileStream stream, Uint8List chunk) async {
    await super.writeChunk(stream, chunk);
    if (!_fired) {
      _fired = true;
      onFirstChunkWritten();
    }
  }
}

/// Serves the body from a real `ReadableStream` that emits [chunks] and then
/// either stalls or closes. Only the *source* of the bytes is
/// substituted: `read`, `cancel`, and every OPFS write below them run
/// against the browser, so the streams semantics under test are Chrome's,
/// not the fake's.
///
/// The cancel signal errors the stream, which is what the real `fetch` abort
/// controller — still live after the headers — does to a read already in
/// flight, and the only route a cancellation takes now.
class _ScriptedDownload extends OpfsFetchDownload {
  _ScriptedDownload({
    required this.contentLength,
    this.chunks = const [
      [1, 2, 3]
    ],
    this.closeAfterChunks = false,
    this.errorStreamOnSecondRead = false,
  });

  final int contentLength;

  /// The body, sliced the way the browser would hand it over. More than one
  /// entry is what makes the read loop iterate.
  final List<List<int>> chunks;

  final bool closeAfterChunks;

  /// Errors the body stream mid-read with no cancellation involved: a
  /// connection dropping partway through the download.
  final bool errorStreamOnSecondRead;

  web.ReadableStreamDefaultController? _controller;

  /// The rejection a browser produces for an aborted body, not a Dart error,
  /// so the mapping under test is the one production hits.
  void _errorStream() =>
      _controller?.error(web.DOMException('aborted', 'AbortError'));

  final _secondReadStarted = Completer<void>();
  var _readCount = 0;

  /// How many `read()` calls the loop has issued.
  int get readCount => _readCount;

  /// Resolves once the read loop is parked inside its second `read()`.
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
    final chunk = super.readChunk(reader);
    // After `super.readChunk` has started, so the read this rejects is one
    // already in flight.
    if (_readCount == 2 && errorStreamOnSecondRead) _errorStream();
    return chunk;
  }

  @override
  Future<FetchDownloadHandle> openDownload(Uri url,
      {Future<void>? cancelSignal}) async {
    final source = JSObject();
    source.setProperty(
      'start'.toJS,
      ((web.ReadableStreamDefaultController controller) {
        _controller = controller;
        for (final chunk in chunks) {
          controller.enqueue(Uint8List.fromList(chunk).toJS);
        }
        if (closeAfterChunks) controller.close();
      }).toJS,
    );
    final stream = web.ReadableStream(source);
    if (cancelSignal != null) {
      unawaited(cancelSignal.then((_) => _errorStream()));
    }
    return FetchDownloadHandle(
      reader: stream.getReader() as web.ReadableStreamDefaultReader,
      contentLength: contentLength,
    );
  }
}
