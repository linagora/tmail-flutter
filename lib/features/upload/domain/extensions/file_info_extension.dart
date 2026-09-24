
import 'package:file_picker/file_picker.dart';
import 'package:model/upload/file_info.dart';

extension FileInfoExtension on FileInfo {
  FileInfo withInline() => switch (this) {
    FilePathInfo(:final filePath) => FilePathInfo(
      fileName: fileName, fileSize: fileSize, filePath: filePath,
      type: type, isInline: true, isShared: isShared),
    FileBytesInfo(:final bytes) => FileBytesInfo(
      bytes: bytes, fileName: fileName, fileSize: fileSize,
      type: type, isInline: true, isShared: isShared),
    FilePlaceholderInfo() => FilePlaceholderInfo(
      fileName: fileName, fileSize: fileSize,
      type: type, isInline: true, isShared: isShared),
  };

  PlatformFile toPlatformFile() => PlatformFile(
    name: fileName,
    path: switch (this) { FilePathInfo(:final filePath) => filePath, _ => null },
    size: fileSize,
    bytes: switch (this) { FileBytesInfo(:final bytes) => bytes, _ => null },
  );
}
