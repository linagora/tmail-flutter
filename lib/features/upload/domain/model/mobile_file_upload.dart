
import 'package:equatable/equatable.dart';

class MobileFileUpload with EquatableMixin {
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;

  MobileFileUpload(
    this.fileName,
    this.filePath,
    this.fileSize,
    this.mimeType
  );

  @override
  List<Object?> get props => [
    fileName,
    filePath,
    fileSize,
    mimeType,
  ];
}