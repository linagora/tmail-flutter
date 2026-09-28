
import 'package:model/upload/file_info.dart';

extension FileInfoExtension on FileInfo {
  FileInfo withInline() => switch (this) {
    FilePathInfo(:final filePath) => FilePathInfo(
      fileName: fileName, fileSize: fileSize, filePath: filePath,
      type: type, isInline: true, isShared: isShared),
    FileBytesInfo(:final bytes) => FileBytesInfo(
      bytes: bytes, fileName: fileName, fileSize: fileSize,
      type: type, isInline: true, isShared: isShared),
    FileBlobInfo(:final sourceUrl) => FileBlobInfo(
      fileName: fileName, fileSize: fileSize, sourceUrl: sourceUrl, openRead: openRead,
      type: type, isInline: true, isShared: isShared),
    FilePlaceholderInfo() => FilePlaceholderInfo(
      fileName: fileName, fileSize: fileSize,
      type: type, isInline: true, isShared: isShared),
  };
}
