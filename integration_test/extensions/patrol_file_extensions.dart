import 'dart:io';

import 'package:model/upload/file_info.dart';

extension PatrolFileExtensions on File {
  Future<FileInfo> toFileInfo() async {
    final size = await length();
    final name = path.split('/').last;
    return FilePathInfo(
      filePath: path,
      fileSize: size,
      fileName: name,
    );
  }
}