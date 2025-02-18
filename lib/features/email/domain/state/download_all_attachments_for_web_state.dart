import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dio/dio.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';

class StartDownloadAllAttachmentsForWeb extends UIState {
  StartDownloadAllAttachmentsForWeb(this.taskId, this.attachment, {this.cancelToken});

  final DownloadTaskId taskId;
  final Attachment attachment;
  final CancelToken? cancelToken;

  @override
  List<Object?> get props => [taskId, attachment, cancelToken];
}

class DownloadingAllAttachmentsForWeb extends LoadingState {
  DownloadingAllAttachmentsForWeb(
    this.taskId,
    this.fileName,
    this.progress,
    this.downloaded,
    this.total,
  );

  final DownloadTaskId taskId;
  final String fileName;
  final double progress;
  final int downloaded;
  final int total;

  @override
  List<Object?> get props => [taskId, fileName, progress, downloaded, total];
}

class DownloadAllAttachmentsForWebSuccess extends UIState {
  DownloadAllAttachmentsForWebSuccess({required this.taskId});

  final DownloadTaskId taskId;

  @override
  List<Object> get props => [taskId];
}

class DownloadAllAttachmentsForWebFailure extends FeatureFailure {
  DownloadAllAttachmentsForWebFailure({super.exception, required this.taskId, this.cancelToken});

  final DownloadTaskId taskId;
  final CancelToken? cancelToken;

  @override
  List<Object?> get props => [exception, taskId, cancelToken];
}