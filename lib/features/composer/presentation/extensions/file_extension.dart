
import 'dart:io';

import 'package:model/upload/file_info.dart';

extension FileExtension on File {
  FileInfo toFileInfo({
    bool? isInline,
    bool? isShared
  }) {
    return FilePathInfo(
      fileName: path.split('/').last,
      fileSize: existsSync() ? lengthSync() : 0,
      filePath: path,
      isInline: isInline,
      isShared: isShared
    );
  }
}