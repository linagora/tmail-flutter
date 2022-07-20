
import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:dio/dio.dart';

class UploadAttachment extends Equatable {

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

  Future<void> upload() async {
    log('UploadFile::upload(): $uploadTaskId');
    _updateEvent(Right(PendingAttachmentUploadState(uploadTaskId, 0, fileInfo.fileSize)));

    final attachment = await fileUploader.uploadAttachment(
        uploadTaskId,
        _progressStateController,
        fileInfo,
        uploadUri,
        cancelToken: cancelToken);

    if (cancelToken?.isCancelled == true) {
      _updateEvent(Left(CancelAttachmentUploadState(uploadTaskId)));
      await _progressStateController.close();
      return;
    }

    if (attachment != null) {
      _updateEvent(Right(SuccessAttachmentUploadState(uploadTaskId, attachment, fileInfo)));
    } else {
      _updateEvent(Left(ErrorAttachmentUploadState(uploadTaskId)));
    }
    await _progressStateController.close();
  }

  @override
  List<Object?> get props => [uploadTaskId, fileInfo, uploadUri];
}