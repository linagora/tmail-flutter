
import 'package:equatable/equatable.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';

class DownloadTaskState with EquatableMixin {
  final DownloadTaskId taskId;
  final Attachment attachment;
  final double progress;
  final int downloaded;
  final int total;

  DownloadTaskState({
    required this.taskId,
    required this.attachment,
    this.progress = 0,
    this.downloaded = 0,
    this.total = 0
  });

  DownloadTaskState copyWith({
    DownloadTaskId? taskId,
    Attachment? attachment,
    double? progress,
    int? downloaded,
    int? total
  }) {
    return DownloadTaskState(
      taskId: taskId ?? this.taskId,
      attachment: attachment ?? this.attachment,
      progress: progress ?? this.progress,
      downloaded: downloaded ?? this.downloaded,
      total: total ?? this.total
    );
  }

  double get percentDownloading => progress / 100;

  @override
  List<Object?> get props => [taskId, attachment, progress, downloaded, total];
}