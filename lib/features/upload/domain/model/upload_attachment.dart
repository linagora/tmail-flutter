
import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

class UploadAttachment with EquatableMixin {

  final UploadTaskId uploadTaskId;
  final FileInfo fileInfo;
  final Uri uploadUri;
  final FileUploader fileUploader;
  final CancelToken? cancelToken;

  final StreamController<Either<Failure, Success>> _progressStateController
    = StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get progressState => _progressStateController.stream;

  UploadAttachment(
    this.uploadTaskId,
    this.fileInfo,
    this.uploadUri,
    this.fileUploader,
    {this.cancelToken});

  void _updateEvent(Either<Failure, Success> flowUploadState) {
    _progressStateController.add(flowUploadState);
  }

  void upload() async {
    try {
      log('UploadFile::upload(): $uploadTaskId');
      _updateEvent(Right(PendingAttachmentUploadState(uploadTaskId, 0, fileInfo.fileSize)));

      final attachment = await fileUploader.uploadAttachment(
        uploadTaskId,
        fileInfo,
        uploadUri,
        cancelToken: cancelToken,
        onSendController: _progressStateController,
      );

      log('UploadAttachment::upload: ATTACHMENT_UPLOADED = $attachment');

      if (cancelToken?.isCancelled == true) {
        _updateEvent(Left(CancelAttachmentUploadState(uploadTaskId)));
        await _progressStateController.close();
        return;
      }

      _updateEvent(Right(SuccessAttachmentUploadState(uploadTaskId, attachment, fileInfo)));
    } catch (e) {
      logError('UploadAttachment::upload():ERROR: $e');
      if (e is DioError && e.type == DioErrorType.cancel) {
        _updateEvent(Left(CancelAttachmentUploadState(uploadTaskId)));
      } else {
        _updateEvent(Left(ErrorAttachmentUploadState(uploadId: uploadTaskId)));
      }
    } finally {
      await _progressStateController.close();
    }
  }

  @override
  List<Object?> get props => [
    uploadTaskId,
    fileInfo,
    uploadUri,
    fileUploader,
    cancelToken
  ];
}