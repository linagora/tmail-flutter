import 'dart:async';
import 'dart:math' show Random;

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader_web.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/domain/entity/drive_document.dart';

/// Streams a drive document into an Origin Private File System temp file.
/// Web-only: this file (and its `package:web`-touching [OpfsJsBindings]
/// dependency) is only ever imported by the web branch of
/// `DriveTransferStrategyFactory`.
class OpfsDriveFileStager implements DriveFileStager {
  final OpfsJsBindings _bindings;

  OpfsDriveFileStager({OpfsJsBindings? bindings})
      : _bindings = bindings ?? OpfsJsBindings.instance;

  @override
  Future<StagedDriveFile> stage({
    required DriveDocument doc,
    required void Function(int received, int total) onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    final tempFileName = '${doc.id}_${_uniqueSuffix()}_${doc.name}';

    OpfsFetchStream? fetchStream;
    dynamic handle;
    dynamic writable;
    Future<void>? cancelSubscription;
    // Guards the listener below from firing on a stale reader once stage()
    // has already returned or thrown — a bare `whenCancel.then(...)` has no
    // unsubscribe, so it otherwise stays registered for the token's lifetime.
    var completed = false;

    try {
      fetchStream = await _bindings.fetchStream(
        doc.downloadLink!,
        cancelSignal: cancelToken.whenCancel,
      );
      handle = await _bindings.createTempFile(tempFileName);
      writable = await _bindings.openWritable(handle);

      final reader = fetchStream.reader;
      cancelSubscription = cancelToken.whenCancel.then((_) {
        if (!completed) _bindings.cancelReader(reader);
      });

      final received = await _streamToFile(
        fetchStream: fetchStream,
        writable: writable,
        cancelToken: cancelToken,
        onDownloadProgress: onDownloadProgress,
      );
      await _bindings.closeWritable(writable);
      completed = true;
      return OpfsStagedFile(
        fileHandle: handle,
        removeEntry: (_) => _bindings.removeTempFile(tempFileName),
        fileName: doc.name,
        fileSize: received,
        mimeType: doc.mimeType,
      );
    } catch (e) {
      completed = true;
      await _cleanupAfterFailure(
        tempFileName: tempFileName,
        fetchStream: fetchStream,
        writable: writable,
        handle: handle,
      );
      rethrow;
    } finally {
      if (cancelSubscription != null) unawaited(cancelSubscription);
    }
  }

  Future<int> _streamToFile({
    required OpfsFetchStream fetchStream,
    required dynamic writable,
    required CancelToken cancelToken,
    required void Function(int received, int total) onDownloadProgress,
  }) async {
    final reader = fetchStream.reader;
    var received = 0;
    while (true) {
      if (cancelToken.isCancelled) {
        throw StateError('OpfsDriveFileStager: transfer cancelled');
      }
      final chunk = await _bindings.readChunk(reader);
      if (chunk == null) break;
      await _bindings.writeChunk(writable, chunk);
      received += chunk.length;
      onDownloadProgress(received, fetchStream.contentLength);
    }
    return received;
  }

  Future<void> _cleanupAfterFailure({
    required String tempFileName,
    required OpfsFetchStream? fetchStream,
    required dynamic writable,
    required dynamic handle,
  }) async {
    if (fetchStream != null) {
      try {
        await _bindings.cancelReader(fetchStream.reader);
      } catch (cleanupError) {
        logWarning('OpfsDriveFileStager: failed to cancel reader for $tempFileName: $cleanupError');
      }
    }
    if (writable != null) {
      try {
        await _bindings.abortWritable(writable);
      } catch (cleanupError) {
        logWarning('OpfsDriveFileStager: failed to abort writable for $tempFileName: $cleanupError');
      }
    }
    if (handle != null) {
      try {
        await _bindings.removeTempFile(tempFileName);
      } catch (cleanupError) {
        logWarning('OpfsDriveFileStager: failed to remove temp file $tempFileName: $cleanupError');
      }
    }
  }

  static final _random = Random();

  /// Distinguishes simultaneous transfers of the same [DriveDocument] so
  /// they don't collide on the same OPFS entry name.
  static String _uniqueSuffix() =>
      '${DateTime.now().microsecondsSinceEpoch}${_random.nextInt(1000000)}';
}

/// Web+OPFS strategy: flat memory on both legs (streamed download to OPFS,
/// streamed upload from OPFS via raw XHR).
class OpfsDriveTransferStrategy implements DriveTransferStrategy {
  @override
  final DriveFileStager stager;

  @override
  final OpfsDriveFileUploader opfsUploader;

  OpfsDriveTransferStrategy({
    DriveFileStager? stager,
    OpfsDriveFileUploader? opfsUploader,
  })  : stager = stager ?? OpfsDriveFileStager(),
        opfsUploader = opfsUploader ?? BrowserOpfsDriveFileUploader();
}
