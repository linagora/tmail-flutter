import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

/// Renders a chip for a queued drive file before its transfer starts.
class DriveTransferPlaceholder {
  final UploadTaskId taskId;
  final String fileName;
  final int fileSize;
  final String? mimeType;
  final CancelToken? cancelToken;

  const DriveTransferPlaceholder({
    required this.taskId,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    this.cancelToken,
  });
}
