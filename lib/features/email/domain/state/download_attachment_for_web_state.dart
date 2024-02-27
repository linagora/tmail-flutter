import 'dart:typed_data';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';

class IdleDownloadAttachmentForWeb extends UIState {}

class StartDownloadAttachmentForWeb extends UIState {

  final DownloadTaskId taskId;
  final Attachment attachment;

  StartDownloadAttachmentForWeb(this.taskId, this.attachment);

  @override
  List<Object> get props => [taskId, attachment];
}

class DownloadingAttachmentForWeb extends UIState {

  final DownloadTaskId taskId;
  final Attachment attachment;
  final double progress;
  final int downloaded;
  final int total;

  DownloadingAttachmentForWeb(
    this.taskId,
    this.attachment,
    this.progress,
    this.downloaded,
    this.total
  );

  @override
  List<Object> get props => [
    taskId,
    attachment,
    progress,
    downloaded,
    total
  ];
}

class DownloadAttachmentForWebSuccess extends UIState {

  final DownloadTaskId taskId;
  final Attachment attachment;
  final Uint8List bytes;

  DownloadAttachmentForWebSuccess(this.taskId, this.attachment, this.bytes);

  @override
  List<Object> get props => [taskId, attachment, bytes];
}

class DownloadAttachmentForWebFailure extends FeatureFailure {

  final DownloadTaskId? taskId;
  final Id? attachmentBlobId;

  DownloadAttachmentForWebFailure({
    required this.attachmentBlobId,
    this.taskId,
    dynamic exception
  }) : super(exception: exception);

  @override
  List<Object?> get props => [taskId, ...super.props];
}