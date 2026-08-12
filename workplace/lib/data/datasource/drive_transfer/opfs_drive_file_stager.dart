import 'dart:math' show Random;

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dio/dio.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_download_source.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_fetch_download.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_store.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/drive_document_extension.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

/// Streams a drive document into an Origin Private File System temp file.
/// Web-only: this file (and the `package:web`-touching implementations behind
/// [DriveDownloadSource] and [OpfsStore]) is only ever imported by the web
/// branch of `DriveTransferStrategyFactory`.
class OpfsDriveFileStager implements DriveFileStager<OpfsStagedFile> {
  final DriveDownloadSource _download;
  final OpfsStore _store;
  final bool _isReleaseMode;

  OpfsDriveFileStager({
    DriveDownloadSource? download,
    OpfsStore? store,
    bool? isReleaseMode,
  })  : _download = download ?? OpfsFetchDownload(),
        _store = store ?? OpfsFileOps(),
        _isReleaseMode = isReleaseMode ?? BuildUtils.isReleaseMode;

  /// Cancellation runs entirely through [DriveDownloadSource.openDownload]'s
  /// abort signal: it rejects the `fetch` before the headers land and errors
  /// the body stream after, so a cancelled transfer always leaves here by
  /// throwing. Nothing else listens on the token — a second listener that
  /// closed the reader quietly would let a truncated download read as a
  /// complete one on a response with no content-length.
  @override
  Future<OpfsStagedFile> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    final downloadLink = doc.resolveDownloadLinkForStaging(
      isReleaseMode: _isReleaseMode,
    );
    final tempFileName = _tempFileName(doc);

    final scope = _OpfsStagingScope(
      download: _download,
      store: _store,
      tempFileName: tempFileName,
    );

    try {
      final downloadHandle = scope.downloadHandle = await _download.openDownload(
        downloadLink,
        cancelSignal: cancelToken.whenCancel,
      );
      final handle = scope.handle = await _store.createTempFile(tempFileName);
      final writable = scope.writable = await _store.openWritable(handle);

      final received = await _streamToFile(_StreamToFileRequest(
        downloadHandle: downloadHandle,
        writable: writable,
        onDownloadProgress: onDownloadProgress,
      ));
      await _store.closeWritable(writable);
      scope.releaseReaderLock();
      return OpfsStagedFile(
        fileHandle: handle,
        removeEntry: (_) => _store.removeTempFile(tempFileName),
        fileName: doc.name,
        fileSize: received,
        mimeType: doc.mimeType,
      );
    } catch (e) {
      await scope.cleanupAfterFailure();
      throw _asDioFailure(e, cancelToken, downloadLink);
    } finally {
      scope.release();
    }
  }

  /// The one place a staging failure is shaped, so callers only ever branch on
  /// [DioExceptionType]. Without it the OPFS half of the pipeline —
  /// `createTempFile`, `openWritable`, `writeChunk`, `closeWritable` — would
  /// surface raw browser errors (`QuotaExceededError` on a full disk, a bare
  /// `DOMException`) that no caller can classify. The download half already
  /// arrives Dio-shaped and passes through untouched.
  static Object _asDioFailure(Object error, CancelToken cancelToken, Uri url) {
    final requestOptions = RequestOptions(path: url.toString());
    // Checked first: a cancellation reaches here as whatever the browser threw
    // when the abort landed, and only the token can identify it. Callers show
    // an error for anything else, so misreading this shows a toast on a
    // transfer the user cancelled themselves.
    if (cancelToken.isCancelled) {
      return DioException.requestCancelled(
        requestOptions: requestOptions,
        reason: 'drive staging was cancelled',
      );
    }
    // Carries its own received/expected counts; flattening it would lose them.
    if (error is DriveDownloadIncompleteException) return error;
    if (error is DioException) return error;
    // Spelled out rather than via a `DioException` factory, which hardcodes
    // `error: null` and would drop the browser's own failure — the same reason
    // `OpfsFetchDownload.openDownload` builds its own.
    return DioException(
      type: DioExceptionType.unknown,
      requestOptions: requestOptions,
      error: error,
      message: 'drive staging failed',
    );
  }

  Future<int> _streamToFile(_StreamToFileRequest request) async {
    final received = await _readAndWriteAll(request);
    _verifyComplete(request, received);
    return received;
  }

  /// Pumps the response body into the OPFS temp file one chunk at a time.
  ///
  /// **Why chunk-at-a-time.** This stager exists so a drive document never has
  /// to fit in the JS heap. `BufferedWebDriveFileStager` — the fallback for
  /// browsers without OPFS — holds the whole body as bytes before it uploads,
  /// and that is what caps the document size a transfer survives. Here the
  /// bytes go fetch → OPFS entry incrementally, so peak memory is one chunk
  /// whatever the document weighs, and the upload leg streams that entry back
  /// out through XHR. Anything that materialises the body whole (reading the
  /// response into one `Uint8List`) hands the old memory profile back.
  ///
  /// **Why nothing bounds the loop up front.** The chunk count is not knowable.
  /// `content-length` is a total byte count — absent on chunked responses, -1
  /// here — and says nothing about how the browser slices the body; chunk sizes
  /// vary with the network and the browser's own buffering. The stream
  /// announces its end itself, and the only way to observe that is
  /// `reader.read()` resolving `done: true`, which [OpfsFetchDownload.readChunk]
  /// maps to null. So the value that ends the loop is produced by an operation
  /// that has to run inside it.
  ///
  /// **Why `while (true)`.** With the exit condition only available after a
  /// read, every header-test shape costs something. Assigning in the condition,
  /// `while ((chunk = await readChunk(reader)) != null)`, does not promote
  /// `chunk` in the body — the assignment is also reachable from the loop's
  /// back edge — so every use needs `chunk!`. A three-clause
  /// `for (var chunk = await readChunk(reader); chunk != null; chunk = await readChunk(reader))`
  /// does promote, but writes the read twice. `while (true)` with one read and
  /// an explicit `break` on the sentinel keeps a single read and no `!`.
  ///
  /// JS `for await...of` over the `ReadableStream` is not reachable:
  /// `dart:js_interop` has no async-iterator bridge, the same reason
  /// [OpfsFileOps.sweepStaleTempFiles] drives `keys()` by hand. The one
  /// genuinely loop-free option is handing the pump to the browser —
  /// `body.pipeTo(writable)` with a `TransformStream` counting progress —
  /// which would replace this file's read/write bindings wholesale.
  ///
  /// Nothing guards a step of the pump itself: every failure on either side of
  /// it is shaped once by [_asDioFailure] on the way out of [stage]. The
  /// progress callback is the exception, being no part of the transfer.
  Future<int> _readAndWriteAll(_StreamToFileRequest request) async {
    final reader = request.downloadHandle.reader;
    var received = 0;
    while (true) {
      final chunk = await _download.readChunk(reader);
      if (chunk == null) break;
      await _store.writeChunk(request.writable, chunk);
      received += chunk.length;
      // Guarded for the same reason `OpfsXhrUpload` guards its upload
      // counterpart: the callback belongs to the caller, and a throw from it
      // would unwind the pump and bin a transfer that is otherwise healthy —
      // never worth losing one over a progress report.
      try {
        request.onDownloadProgress(received, request.downloadHandle.contentLength);
      } catch (e) {
        logWarning('OpfsDriveFileStager: download progress callback failed: $e');
      }
    }
    return received;
  }

  /// A server that closes early ends the stream normally, so without this the
  /// truncated file would pass as a successful staging. Only checkable when the
  /// response declared a length.
  ///
  /// Short reads only: `content-length` is not always the delivered byte count.
  /// A `content-encoding` response declares the compressed size while `fetch`
  /// hands over the decompressed body, so a complete transfer legitimately
  /// overruns it. (A length hidden by CORS parses to -1 and skips the check.)
  void _verifyComplete(_StreamToFileRequest request, int received) {
    final expected = request.downloadHandle.contentLength;
    if (expected >= 0 && received < expected) {
      throw DriveDownloadIncompleteException(
        received: received,
        expected: expected,
      );
    }
  }

  /// `<opfsTempFilePrefix><micros>_<random>_<id>_<name>`: the timestamp ages
  /// the entry for `sweepStaleTempFiles`, the random field keeps simultaneous
  /// transfers of one [DriveDocument] off each other's entry.
  ///
  /// Separators are stripped because `getFileHandle` rejects them; always
  /// prefixed, so the name can never come out as `.` or `..`.
  static String _tempFileName(DriveDocument doc) {
    final unique =
        '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1000000)}';
    final tail = '${doc.id}_${doc.name}'.replaceAll(_pathSeparators, '_');
    return '$opfsTempFilePrefix${unique}_$tail';
  }

  static final _random = Random();
  static final _pathSeparators = RegExp(r'[/\\]');
}

/// Bundles [OpfsDriveFileStager._streamToFile]'s parameters to keep its
/// argument count low, the same way `XhrUploadFileRequest` does.
class _StreamToFileRequest {
  final FetchDownloadHandle downloadHandle;

  /// `dynamic`, not `web.FileSystemWritableFileStream`: naming that type here
  /// would pull `package:web` into a file the non-web build still analyses.
  /// Only [OpfsStore] touches it.
  final dynamic writable;

  final OnFileProcessedProgress onDownloadProgress;

  const _StreamToFileRequest({
    required this.downloadHandle,
    required this.writable,
    required this.onDownloadProgress,
  });
}

/// The resources one `stage()` call has acquired so far. Owning the cleanup
/// keeps `stage` from carrying three mutable locals just to hand them over.
class _OpfsStagingScope {
  final DriveDownloadSource download;
  final OpfsStore store;
  final String tempFileName;

  FetchDownloadHandle? downloadHandle;
  OpfsFileHandle? handle;

  /// See [_StreamToFileRequest.writable] for why this stays untyped.
  dynamic writable;

  _OpfsStagingScope({
    required this.download,
    required this.store,
    required this.tempFileName,
  });

  /// Drops the references `stage()` no longer needs once the transfer ends.
  void release() {
    downloadHandle = null;
    writable = null;
    handle = null;
  }

  /// Hands the stream's lock back once nothing will read from it again. Safe
  /// on an already-unlocked reader, and never worth failing a finished
  /// transfer over.
  void releaseReaderLock() {
    final stream = downloadHandle;
    if (stream == null) return;
    try {
      download.releaseReaderLock(stream.reader);
    } catch (e) {
      logWarning('OpfsDriveFileStager: failed to release the reader lock for $tempFileName: $e');
    }
  }

  /// Best-effort: every step runs regardless of the ones before it, and a
  /// failure here is logged rather than replacing the error that caused it.
  Future<void> cleanupAfterFailure() async {
    final stream = downloadHandle;
    if (stream != null) {
      await _attempt('cancel reader', () => download.cancelReader(stream.reader));
      releaseReaderLock();
    }
    final openWritable = writable;
    if (openWritable != null) {
      final aborted = await _attempt(
          'abort writable', () => store.abortWritable(openWritable));
      // A still-open writable holds a lock on the entry, and `removeEntry` on
      // a locked entry fails — so the half-written file the abort was meant to
      // discard would survive instead. `close()` commits the partial bytes,
      // but the removal below deletes them, and it is the only way left to
      // release the lock.
      if (!aborted) {
        await _attempt('close writable after failed abort',
            () => store.closeWritable(openWritable));
      }
    }
    // Unconditional: removing an entry that was never created just fails, and
    // `_attempt` already logs and swallows that.
    await _attempt('remove temp file', () => store.removeTempFile(tempFileName));
  }

  /// Returns whether [action] succeeded, so a step can react to the one before
  /// it having failed.
  Future<bool> _attempt(String step, Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (cleanupError) {
      logWarning('OpfsDriveFileStager: failed to $step for $tempFileName: $cleanupError');
      return false;
    }
  }
}
