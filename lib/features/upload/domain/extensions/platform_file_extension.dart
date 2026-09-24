import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:model/upload/file_info.dart';

extension PlatformFileExtension on PlatformFile {
  FileInfo toFileInfo() {
    if (PlatformInfo.isWeb) {
      final pickedBytes = bytes;
      return pickedBytes == null
        ? FilePlaceholderInfo(fileName: name, fileSize: size)
        : FileBytesInfo(bytes: pickedBytes, fileName: name, fileSize: size);
    }
    final localPath = path;
    if (localPath == null || localPath.isEmpty) {
      return FilePlaceholderInfo(fileName: name, fileSize: size);
    }
    return FilePathInfo(fileName: name, fileSize: size, filePath: localPath);
  }
}
