import 'dart:typed_data';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dio/dio.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';

class IdleDownloadAttachmentForWeb extends UIState {}

class StartDownloadAttachmentForWeb extends UIState {

  final DownloadTaskId taskId;
  final Attachment attachment;
  final CancelToken? cancelToken;
  final bool previewerSupported;

  StartDownloadAttachmentForWeb(this.taskId, this.attachment, [this.cancelToken, this.previewerSupported = false]);

  @override
  List<Object?> get props => [taskId, attachment, cancelToken, previewerSupported];
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
  final bool previewerSupported;

  DownloadAttachmentForWebSuccess(this.taskId, this.attachment, this.bytes, this.previewerSupported);

  @override
  List<Object> get props => [taskId, attachment, bytes, previewerSupported];
}

class DownloadAttachmentForWebFailure extends FeatureFailure {

  final DownloadTaskId? taskId;
  final Attachment? attachment;
  final CancelToken? cancelToken;

  DownloadAttachmentForWebFailure({
    this.attachment,
    this.taskId,
    this.cancelToken,
    super.exception
  });

  @override
  List<Object?> get props => [attachment, taskId, cancelToken, ...super.props];
}