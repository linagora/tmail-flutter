import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:model/model.dart';

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

  final DownloadTaskId taskId;
  final dynamic exception;

  DownloadAttachmentForWebFailure(this.taskId, this.exception);

  @override
  List<Object> get props => [taskId, exception];
}