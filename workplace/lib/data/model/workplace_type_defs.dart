import 'dart:async';

import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';

typedef OnFileProcessedProgress = void Function(int processed, int total);

typedef OnDeleteIOFile = Future<void> Function(String path);
typedef OnDeleteOPFSFile = Future<void> Function(OpfsFileHandle handle);

/// Uploads a staged drive file through the app's `FileUploader`. Injected by
/// the main app, which `workplace` cannot depend on.
typedef StagedFileUploader = Future<Attachment> Function({
  required StagedDriveFile staged,
  required Uri uploadUri,
  required OnFileProcessedProgress onUploadProgress,
  required CancelToken cancelToken,
});
