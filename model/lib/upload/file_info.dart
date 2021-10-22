
import 'package:equatable/equatable.dart';
import 'package:mime/mime.dart';

class FileInfo with EquatableMixin {
  final String fileName;
  final String filePath;
  final int fileSize;

  FileInfo(this.fileName, this.filePath, this.fileSize);

  factory FileInfo.empty() {
    return FileInfo('', '', 0);
  }

  String get mimeType => lookupMimeType(filePath) ?? 'application/json; charset=UTF-8';

  @override
  List<Object> get props => [fileName, filePath, fileSize];
}