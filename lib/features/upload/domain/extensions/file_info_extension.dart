
import 'package:file_picker/file_picker.dart';
import 'package:model/upload/file_info.dart';

extension FileInfoExtension on FileInfo {
  FileInfo withInline() => FileInfo(
    fileName: fileName,
    fileSize: fileSize,
    filePath: filePath,
    bytes: bytes,
    type: type,
    isInline: true,
    isShared: isShared);

  PlatformFile toPlatformFile() => PlatformFile(
    name: fileName,
    path: filePath,
    size: fileSize,
    bytes: bytes,
  );
}