import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader_web.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';

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
