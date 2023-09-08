
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
  final bool fromFileShared;

  SuccessAttachmentUploadState(
    this.uploadId,
    this.attachment,
    this.fileInfo,
    {
      this.fromFileShared = false
    }
  );

  @override
  List<Object?> get props => [
    uploadId,
    attachment,
    fileInfo,
    fromFileShared,
  ];
}

class ErrorAttachmentUploadState extends Failure {
  final UploadTaskId uploadId;

  ErrorAttachmentUploadState(this.uploadId);

  @override
  List<Object?> get props => [uploadId];
}

class CancelAttachmentUploadState extends Failure {
  final UploadTaskId uploadId;

  CancelAttachmentUploadState(this.uploadId);

  @override
  List<Object?> get props => [uploadId];
}