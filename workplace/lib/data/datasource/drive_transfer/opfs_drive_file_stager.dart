import 'dart:async';
import 'dart:math' show Random;

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader_web.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_fetch_streaming.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/drive_document_extension.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

/// Streams a drive document into an Origin Private File System temp file.
/// Web-only: this file (and its `package:web`-touching [OpfsJsBindings]
/// dependency) is only ever imported by the web branch of
/// `DriveTransferStrategyFactory`.
class OpfsDriveFileStager implements DriveFileStager<OpfsStagedFile> {
  final OpfsJsBindings _bindings;
  final bool _isReleaseMode;

  OpfsDriveFileStager({OpfsJsBindings? bindings, bool? isReleaseMode})
      : _bindings = bindings ?? OpfsJsBindings.instance,
        _isReleaseMode = isReleaseMode ?? BuildUtils.isReleaseMode;

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
      bindings: _bindings,
      tempFileName: tempFileName,
    );
    Future<void>? cancelSubscription;

    try {
      final fetchStream = scope.fetchStream = await _bindings.fetchStream(
        downloadLink,
        cancelSignal: cancelToken.whenCancel,
      );
      final handle = scope.handle = await _bindings.createTempFile(tempFileName);
      final writable = scope.writable = await _bindings.openWritable(handle);

      // Reads the reader off the scope rather than capturing it: a bare
      // `whenCancel.then(...)` has no unsubscribe, so this listener outlives
      // stage() for as long as the token does. `scope.release()` below empties
      // what it can still reach, which both stops it acting on a finished
      // transfer and drops its hold on the reader.
      cancelSubscription = cancelToken.whenCancel.then((_) async {
        final activeReader = scope.fetchStream?.reader;
        if (activeReader != null) await _bindings.cancelReader(activeReader);
      }).catchError((error) {
        logWarning('OpfsDriveFileStager: failed to cancel reader for $tempFileName: $error');
      });

      final received = await _streamToFile(_StreamToFileRequest(
        fetchStream: fetchStream,
        writable: writable,
        cancelToken: cancelToken,
        onDownloadProgress: onDownloadProgress,
      ));
      await _bindings.closeWritable(writable);
      scope.releaseReaderLock();
      return OpfsStagedFile(
        fileHandle: handle,
        removeEntry: (_) => _bindings.removeTempFile(tempFileName),
        fileName: doc.name,
        fileSize: received,
        mimeType: doc.mimeType,
      );
    } catch (e) {
      await scope.cleanupAfterFailure();
      rethrow;
    } finally {
      scope.release();
      if (cancelSubscription != null) unawaited(cancelSubscription);
    }
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
  /// `reader.read()` resolving `done: true`, which [OpfsFetchStreaming.readChunk]
  /// maps to null. So the value that ends the loop is produced by an operation
  /// that has to run inside it.
  ///
  /// **Why `while (true)`.** With the exit condition only available after a
  /// read, every header-test shape costs something. Assigning in the condition,
  /// `while ((chunk = await readChunk(reader)) != null)`, does not promote
  /// `chunk` in the body — the assignment is also reachable from the loop's
  /// back edge — so every use needs `chunk!`. A three-clause
  /// `for (var chunk = await readChunk(reader); chunk != null; chunk = await readChunk(reader))`
  /// does promote, but writes the read twice and performs its seeding read
  /// before the cancel check below. `while (true)` with one read and an
  /// explicit `break` on the sentinel keeps a single read, no `!`, and the
  /// cancel check first.
  ///
  /// JS `for await...of` over the `ReadableStream` is not reachable:
  /// `dart:js_interop` has no async-iterator bridge, the same reason
  /// [OpfsFileOps.sweepStaleTempFiles] drives `keys()` by hand. The one
  /// genuinely loop-free option is handing the pump to the browser —
  /// `body.pipeTo(writable)` with a `TransformStream` counting progress —
  /// which would replace this file's read/write bindings wholesale.
  Future<int> _readAndWriteAll(_StreamToFileRequest request) async {
    final reader = request.fetchStream.reader;
    var received = 0;
    while (true) {
      // Bails out at the iteration boundary. `cancelReader` is async, so
      // without this the loop would keep reading and writing chunks until the
      // cancellation propagated through the JS reader.
      _throwIfCancelled(request.cancelToken);
      final Uint8List? chunk;
      try {
        chunk = await _bindings.readChunk(reader);
      } catch (_) {
        // The fetch abort controller stays live after the headers, so a
        // cancellation landing mid-read surfaces as a transport failure. The
        // token is the only thing that can tell the two apart, and callers
        // branch on `DioExceptionType.cancel`.
        _throwIfCancelled(request.cancelToken);
        rethrow;
      }
      if (chunk == null) break;
      await _bindings.writeChunk(request.writable, chunk);
      received += chunk.length;
      request.onDownloadProgress(received, request.fetchStream.contentLength);
    }
    return received;
  }

  /// `cancelReader` resolves an in-flight `read()` with done:true rather than
  /// rejecting, so a mid-read cancellation exits the loop normally — without
  /// the re-check here the truncated file would pass as a successful staging.
  void _verifyComplete(_StreamToFileRequest request, int received) {
    _throwIfCancelled(request.cancelToken);
    final expected = request.fetchStream.contentLength;
    if (expected >= 0 && received != expected) {
      throw DriveDownloadIncompleteException(
        received: received,
        expected: expected,
      );
    }
  }

  /// The `??` fallback is unreachable in practice — Dio defines `isCancelled`
  /// as `cancelError != null` — and only keeps a cancelled transfer from being
  /// reported as a success should that ever stop holding.
  static void _throwIfCancelled(CancelToken cancelToken) {
    if (!cancelToken.isCancelled) return;
    throw cancelToken.cancelError ??
        DioException.requestCancelled(
          requestOptions: RequestOptions(path: ''),
          reason: 'drive staging was cancelled',
        );
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
/// argument count low, the same way [XhrUploadFileRequest] does.
class _StreamToFileRequest {
  final OpfsFetchStream fetchStream;

  /// `dynamic`, not `web.FileSystemWritableFileStream`: naming that type here
  /// would pull `package:web` into a file the non-web build still analyses.
  /// Only the bindings touch it.
  final dynamic writable;

  final CancelToken cancelToken;
  final OnFileProcessedProgress onDownloadProgress;

  const _StreamToFileRequest({
    required this.fetchStream,
    required this.writable,
    required this.cancelToken,
    required this.onDownloadProgress,
  });
}

/// The resources one `stage()` call has acquired so far. Owning the cleanup
/// keeps `stage` from carrying three mutable locals just to hand them over.
class _OpfsStagingScope {
  final OpfsJsBindings bindings;
  final String tempFileName;

  OpfsFetchStream? fetchStream;
  OpfsFileHandle? handle;

  /// See [_StreamToFileRequest.writable] for why this stays untyped.
  dynamic writable;

  _OpfsStagingScope({required this.bindings, required this.tempFileName});

  /// Drops the references `stage()` no longer needs, so the `whenCancel`
  /// listener it can never unsubscribe holds nothing once the transfer ends.
  void release() {
    fetchStream = null;
    writable = null;
    handle = null;
  }

  /// Hands the stream's lock back once nothing will read from it again. Safe
  /// on an already-unlocked reader, and never worth failing a finished
  /// transfer over.
  void releaseReaderLock() {
    final stream = fetchStream;
    if (stream == null) return;
    try {
      bindings.releaseReaderLock(stream.reader);
    } catch (e) {
      logWarning('OpfsDriveFileStager: failed to release the reader lock for $tempFileName: $e');
    }
  }

  /// Best-effort: every step runs regardless of the ones before it, and a
  /// failure here is logged rather than replacing the error that caused it.
  Future<void> cleanupAfterFailure() async {
    final stream = fetchStream;
    if (stream != null) {
      await _attempt('cancel reader', () => bindings.cancelReader(stream.reader));
      releaseReaderLock();
    }
    final openWritable = writable;
    if (openWritable != null) {
      final aborted = await _attempt(
          'abort writable', () => bindings.abortWritable(openWritable));
      // A still-open writable holds a lock on the entry, and `removeEntry` on
      // a locked entry fails — so the half-written file the abort was meant to
      // discard would survive instead. `close()` commits the partial bytes,
      // but the removal below deletes them, and it is the only way left to
      // release the lock.
      if (!aborted) {
        await _attempt('close writable after failed abort',
            () => bindings.closeWritable(openWritable));
      }
    }
    if (handle != null) {
      await _attempt(
          'remove temp file', () => bindings.removeTempFile(tempFileName));
    }
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

/// Web+OPFS strategy: flat memory on both legs (streamed download to OPFS,
/// streamed upload from OPFS via raw XHR).
class OpfsDriveTransferStrategy extends DriveTransferStrategy<OpfsStagedFile> {
  OpfsDriveTransferStrategy({
    DriveFileStager<OpfsStagedFile>? stager,
    OpfsDriveFileUploader? uploader,
  })  : _stager = stager ?? OpfsDriveFileStager(),
        _uploader = uploader ?? BrowserOpfsDriveFileUploader();

  final DriveFileStager<OpfsStagedFile> _stager;
  final OpfsDriveFileUploader _uploader;

  @protected
  @override
  Future<OpfsStagedFile> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  }) {
    return _stager.stage(
      doc: doc,
      onDownloadProgress: onDownloadProgress,
      cancelToken: cancelToken,
    );
  }

  @protected
  @override
  Future<Attachment> upload(DriveUploadRequest<OpfsStagedFile> request) {
    final staged = request.staged;
    return _uploader.upload(OpfsUploadRequest(
      fileHandle: staged.fileHandle,
      fileName: staged.fileName,
      uploadUri: request.uploadUri,
      authHeader: request.authHeader,
      mimeType: staged.mimeType,
      onUploadProgress: request.onUploadProgress,
      cancelToken: request.cancelToken,
    ));
  }
}
