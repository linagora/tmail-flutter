
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

class FileInfo with EquatableMixin {
  final String fileName;
  final String filePath;
  final int fileSize;
  final Stream<List<int>>? readStream;

  FileInfo(this.fileName, this.filePath, this.fileSize, {this.readStream});

  factory FileInfo.empty() {
    return FileInfo('', '', 0);
  }

  String get fileExtension => fileName.split('.').last;

  String get mimeType => lookupMimeType(kIsWeb ? fileName : filePath) ?? 'application/json; charset=UTF-8';

  @override
  List<Object?> get props => [fileName, filePath, fileSize, readStream];
}