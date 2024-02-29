import 'package:model/upload/file_info.dart';

extension ListFileInfoExtension on List<FileInfo> {
  List<int> get listSize => map((file) => file.fileSize).toList();

  num get totalSize => listSize.reduce((sum, size) => sum + size);
}