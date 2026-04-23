import 'dart:io';

import 'package:model/upload/file_info.dart';

extension PatrolFileExtensions on File {
  Future<FileInfo> toFileInfo() async {
    final bytes = await readAsBytes();
    final size = bytes.lengthInBytes;
    final name = path.split('/').last;
    return FileInfo(
      filePath: path,
      fileSize: size,
      fileName: name,
      bytes: bytes,
    );
  }
}