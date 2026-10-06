import 'package:core/data/constants/constant.dart';
import 'package:core/utils/platform_info.dart';
import 'package:cross_file/cross_file.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/dropped_file_open_read.dart';

extension XFileExtension on XFile {
  /// Size from the drop event, not a read — a dropped file is never materialised just to measure it.
  Future<FileInfo> toFileInfo() async {
    final fileSize = await length();
    final isInline = mimeType?.startsWith(Constant.imageType) == true;
    if (PlatformInfo.isWeb) {
      return FileBlobInfo(
        fileName: name,
        fileSize: fileSize,
        // On web, path is the drop's own blob URL — same seam the picker uses.
        sourceUrl: path,
        openRead: droppedFileOpenRead(this),
        type: mimeType,
        isInline: isInline,
      );
    }
    return FilePathInfo(fileName: name, fileSize: fileSize, filePath: path, type: mimeType, isInline: isInline);
  }

  /// Size and type of a dropped folder vary by OS; only a read tells it from an empty file.
  Future<bool> isDroppedFolder() async => !await droppedFileIsReadable(this);
}
