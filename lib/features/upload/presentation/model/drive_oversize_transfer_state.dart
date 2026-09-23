import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

enum DriveOversizeTransferStatus { waiting, uploading, linked, failed, cancelled }

extension DriveOversizeTransferStatusExtension on DriveOversizeTransferStatus {
  bool get settled => this != DriveOversizeTransferStatus.waiting
      && this != DriveOversizeTransferStatus.uploading;
}

/// One file of an oversize batch, as the progress dialog renders it.
class DriveOversizeTransferState with EquatableMixin {
  final UploadTaskId taskId;
  final String fileName;
  final int fileSize;
  final int sentBytes;
  final DriveOversizeTransferStatus status;

  /// Cancels this one transfer. Excluded from [props] — identity only.
  final CancelToken cancelToken;

  const DriveOversizeTransferState({
    required this.taskId,
    required this.fileName,
    required this.fileSize,
    required this.cancelToken,
    this.sentBytes = 0,
    this.status = DriveOversizeTransferStatus.waiting,
  });

  /// 0.0-1.0 for the bar; 0 while the total is still unknown.
  double get progress =>
      fileSize <= 0 ? 0 : (sentBytes / fileSize).clamp(0.0, 1.0);

  int get percent => (progress * 100).round();

  DriveOversizeTransferState copyWith({
    int? sentBytes,
    DriveOversizeTransferStatus? status,
  }) => DriveOversizeTransferState(
        taskId: taskId,
        fileName: fileName,
        fileSize: fileSize,
        cancelToken: cancelToken,
        sentBytes: sentBytes ?? this.sentBytes,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [taskId, fileName, fileSize, sentBytes, status];
}
