
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

class PendingAttachmentUploadState extends Success {
  final UploadTaskId uploadId;
  final int progress;
  final int total;

  PendingAttachmentUploadState(this.uploadId, this.progress, this.total);

  @override
  List<Object?> get props => [uploadId, progress, total];
}

class UploadingAttachmentUploadState extends Success {
  final UploadTaskId uploadId;
  final int progress;
  final int total;

  UploadingAttachmentUploadState(this.uploadId, this.progress, this.total);

  @override
  List<Object?> get props => [uploadId, progress, total];
}

class SuccessAttachmentUploadState extends Success {
  final UploadTaskId uploadId;
  final Attachment attachment;
  final FileInfo fileInfo;

  SuccessAttachmentUploadState(
    this.uploadId,
    this.attachment,
    this.fileInfo
  );

  @override
  List<Object?> get props => [
    uploadId,
    attachment,
    fileInfo,
  ];
}

class ErrorAttachmentUploadState extends FeatureFailure {
  final UploadTaskId uploadId;

  ErrorAttachmentUploadState({
    required this.uploadId,
    dynamic exception
  }) : super(exception: exception);

  @override
  List<Object?> get props => [uploadId, ...super.props];
}

class CancelAttachmentUploadState extends Failure {
  final UploadTaskId uploadId;

  CancelAttachmentUploadState(this.uploadId);

  @override
  List<Object?> get props => [uploadId];
}