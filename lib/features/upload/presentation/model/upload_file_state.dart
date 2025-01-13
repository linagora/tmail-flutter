
import 'package:core/presentation/extensions/media_type_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

class UploadFileState with EquatableMixin {

  final FileInfo? file;
  final UploadTaskId uploadTaskId;
  final UploadFileStatus uploadStatus;
  final int uploadingProgress;
  final Attachment? attachment;
  final CancelToken? cancelToken;

  UploadFileState(
    this.uploadTaskId,
    {
      this.file,
      this.uploadStatus = UploadFileStatus.waiting,
      this.uploadingProgress = 0,
      this.attachment,
      this.cancelToken,
    }
  );

  UploadFileState copyWith({
    UploadTaskId? uploadTaskId,
    FileInfo? file,
    UploadFileStatus? uploadStatus,
    int? uploadingProgress,
    Attachment? attachment,
    CancelToken? cancelToken,
  }) {
    return UploadFileState(
      uploadTaskId ?? this.uploadTaskId,
      file: file ?? this.file,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadingProgress: uploadingProgress ?? this.uploadingProgress,
      attachment: attachment ?? this.attachment,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  num get fileSize {
    if (attachment != null) {
      return attachment?.size?.value ?? 0;
    } else if (file != null) {
      return file?.fileSize ?? 0;
    }
    return 0;
  }

  String get fileName {
    if (attachment != null) {
      return attachment?.name ?? '';
    } else if (file != null) {
      return file?.fileName ?? '';
    }
    return '';
  }

  double get percentUploading => uploadingProgress / 100;

  String getIcon(ImagePaths imagePaths) {
    try {
      MediaType? mediaType = attachment?.type;
      if (mediaType == null && file != null) {
        mediaType = MediaType.parse(file!.mimeType);
      }
      return mediaType?.getIcon(imagePaths, fileName: fileName) ?? imagePaths.icFileEPup;
    } catch (e) {
      logError('UploadFileState::getIcon: Exception: $e');
      return imagePaths.icFileEPup;
    }
  }

  @override
  List<Object?> get props => [
    uploadTaskId,
    file,
    uploadStatus,
    uploadingProgress,
    attachment,
    cancelToken,
  ];
}
