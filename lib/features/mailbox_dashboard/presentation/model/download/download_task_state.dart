
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';

class DownloadTaskState with EquatableMixin {
  final DownloadTaskId taskId;
  final Attachment attachment;
  final double progress;
  final int downloaded;
  final int total;
  final VoidCallback? onCancel;

  DownloadTaskState({
    required this.taskId,
    required this.attachment,
    this.progress = 0,
    this.downloaded = 0,
    this.total = 0,
    this.onCancel,
  });

  DownloadTaskState copyWith({
    DownloadTaskId? taskId,
    Attachment? attachment,
    double? progress,
    int? downloaded,
    int? total,
    VoidCallback? onCancel
  }) {
    return DownloadTaskState(
      taskId: taskId ?? this.taskId,
      attachment: attachment ?? this.attachment,
      progress: progress ?? this.progress,
      downloaded: downloaded ?? this.downloaded,
      total: total ?? this.total,
      onCancel: onCancel ?? this.onCancel,
    );
  }

  double get percentDownloading {
    final percent = progress / 100;
    if (percent < 0) {
      return 0;
    } else if (percent > 1) {
      return 1;
    } else {
      return percent;
    }
  }

  @override
  List<Object?> get props => [taskId, attachment, progress, downloaded, total, onCancel];
}