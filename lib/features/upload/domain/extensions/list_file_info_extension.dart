
import 'package:model/upload/file_info.dart';

extension ListFileInfoExtension on List<FileInfo> {
  List<int> get listSize => map((file) => file.fileSize).toList();

  num get totalSize => listSize.isEmpty ? 0 : listSize.reduce((sum, size) => sum + size);

  List<FileInfo> get listInlineFiles => where((fileInfo) => fileInfo.isInline == true).toList();
}