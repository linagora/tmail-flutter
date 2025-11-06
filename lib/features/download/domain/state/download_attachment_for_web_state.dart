import 'dart:typed_data';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dio/dio.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';

class IdleDownloadAttachmentForWeb extends UIState {}

class StartDownloadAttachmentForWeb extends UIState {

  final DownloadTaskId taskId;
  final Attachment attachment;
  final CancelToken? cancelToken;
  final bool previewerSupported;
  final DownloadSourceView? sourceView;

  StartDownloadAttachmentForWeb(
    this.taskId,
    this.attachment, [
    this.cancelToken,
    this.previewerSupported = false,
    this.sourceView,
  ]);

  @override
  List<Object?> get props => [
        taskId,
        attachment,
        cancelToken,
        previewerSupported,
        sourceView,
      ];
}

class DownloadingAttachmentForWeb extends UIState {

  final DownloadTaskId taskId;
  final Attachment attachment;
  final double progress;
  final int downloaded;
  final int total;
  final DownloadSourceView? sourceView;

  DownloadingAttachmentForWeb(
    this.taskId,
    this.attachment,
    this.progress,
    this.downloaded,
    this.total,
    this.sourceView,
  );

  @override
  List<Object?> get props => [
    taskId,
    attachment,
    progress,
    downloaded,
    total,
    sourceView,
  ];
}

class DownloadAttachmentForWebSuccess extends UIState {

  final DownloadTaskId taskId;
  final Attachment attachment;
  final Uint8List bytes;
  final bool previewerSupported;
  final DownloadSourceView? sourceView;

  DownloadAttachmentForWebSuccess(
    this.taskId,
    this.attachment,
    this.bytes,
    this.previewerSupported,
    this.sourceView,
  );

  @override
  List<Object?> get props => [
        taskId,
        attachment,
        bytes,
        previewerSupported,
        sourceView,
      ];
}

class DownloadAttachmentForWebFailure extends FeatureFailure {

  final DownloadTaskId? taskId;
  final Attachment? attachment;
  final CancelToken? cancelToken;
  final DownloadSourceView? sourceView;

  DownloadAttachmentForWebFailure({
    this.attachment,
    this.taskId,
    this.cancelToken,
    this.sourceView,
    super.exception,
  });

  @override
  List<Object?> get props => [
        attachment,
        taskId,
        cancelToken,
        sourceView,
        ...super.props,
      ];
}