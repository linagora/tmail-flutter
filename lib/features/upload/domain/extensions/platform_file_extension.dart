import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';

extension PlatformFileExtension on PlatformFile {
  /// `length()` not `lengthSync()`: a picker that reports no size falls back to
  /// a stat here, instead of sending `content-length: 0`.
  Future<FileInfo> toFileInfo() async {
    // No 0 fallback: the size-limit check runs on `fileSize` before any read,
    // so a false 0 would let an oversized, unreadable-length file skip it.
    final fileSize = await length();
    if (fileSize == null) {
      throw const FileSizeUnavailableException();
    }
    if (PlatformInfo.isWeb) {
      return FileBlobInfo(
        fileName: name,
        fileSize: fileSize,
        sourceUrl: uri.toString(),
        // Web's own stream is already chunked, so the range is redundant here.
        openRead: ([start, end]) => readAsByteStream(),
      );
    }
    final localPath = path;
    if (localPath == null || localPath.isEmpty) {
      return FilePlaceholderInfo(fileName: name, fileSize: fileSize);
    }
    return FilePathInfo(fileName: name, fileSize: fileSize, filePath: localPath);
  }
}
