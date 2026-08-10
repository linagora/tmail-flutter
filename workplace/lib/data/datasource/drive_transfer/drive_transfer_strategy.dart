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
  Future<Attachment> transfer({
    required DriveDocument doc,
    required Uri uploadUri,
    required String authHeader,
    required OnFileProcessedProgress onDownloadProgress,
    required OnFileProcessedProgress onUploadProgress,
    required CancelToken cancelToken,
  }) async {
    final staged = await stage(
      doc: doc,
      onDownloadProgress: onDownloadProgress,
      cancelToken: cancelToken,
    );
    try {
      return await upload(DriveUploadRequest(
        staged: staged,
        uploadUri: uploadUri,
        authHeader: authHeader,
        onUploadProgress: onUploadProgress,
        cancelToken: cancelToken,
      ));
    } finally {
      await staged.dispose();
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
