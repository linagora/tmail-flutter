
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/model/mobile_file_upload.dart';

extension FileInfoExtension on FileInfo {
  MobileFileUpload toMobileFileUpload() => MobileFileUpload(fileName, filePath, fileSize, mimeType);
}