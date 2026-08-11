import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';

/// Both legs of a drive transfer for one platform capability, selected once
/// per batch via `DriveTransferStrategyFactory.create()`. Orchestration —
/// stage, upload, dispose — never branches on platform.
///
/// [transfer] is the only public entry point: it owns the staged file for its
/// whole lifetime and disposes it on every exit path, so callers can neither
/// leak temp storage nor hand a strategy a staged file it can't consume. [T]
/// pins that variant, keeping the pairing a compile-time concern.
abstract class DriveTransferStrategy<T extends StagedDriveFile> {
  Future<Attachment> transfer(DriveTransferRequest request) async {
    final staged = await stage(
      doc: request.doc,
      onDownloadProgress: request.onDownloadProgress,
      cancelToken: request.cancelToken,
    );
    try {
      return await upload(DriveUploadRequest(
        staged: staged,
        uploadUri: request.uploadUri,
        authHeader: request.authHeader,
        onUploadProgress: request.onUploadProgress,
        cancelToken: request.cancelToken,
      ));
    } finally {
      await _disposeQuietly(staged);
    }
  }

  /// Best-effort: a cleanup failure must neither replace the error that caused
  /// it nor turn a completed upload into a failed transfer.
  Future<void> _disposeQuietly(T staged) async {
    try {
      await staged.dispose();
    } catch (error) {
      logWarning(
          'DriveTransferStrategy::_disposeQuietly: failed to dispose staged file: $error');
    }
  }

  @protected
  Future<T> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  });

  @protected
  Future<Attachment> upload(DriveUploadRequest<T> request);
}

/// Bundles [DriveTransferStrategy.transfer]'s parameters to keep its argument
/// count low.
class DriveTransferRequest {
  final DriveDocument doc;
  final Uri uploadUri;

  /// Only used by the OPFS raw-XHR path; the other strategies authenticate
  /// through the app's Dio interceptors.
  final String authHeader;

  final OnFileProcessedProgress onDownloadProgress;
  final OnFileProcessedProgress onUploadProgress;
  final CancelToken cancelToken;

  const DriveTransferRequest({
    required this.doc,
    required this.uploadUri,
    required this.authHeader,
    required this.onDownloadProgress,
    required this.onUploadProgress,
    required this.cancelToken,
  });
}

/// Bundles [DriveTransferStrategy.upload]'s parameters to keep its argument
/// count low.
class DriveUploadRequest<T extends StagedDriveFile> {
  final T staged;
  final Uri uploadUri;

  /// Only used by the OPFS raw-XHR path; the other strategies authenticate
  /// through the app's Dio interceptors.
  final String authHeader;

  final OnFileProcessedProgress onUploadProgress;
  final CancelToken cancelToken;

  const DriveUploadRequest({
    required this.staged,
    required this.uploadUri,
    required this.authHeader,
    required this.onUploadProgress,
    required this.cancelToken,
  });
}
