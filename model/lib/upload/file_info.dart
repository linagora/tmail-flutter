
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

class FileInfo with EquatableMixin {
  final String fileName;
  final String filePath;
  final int fileSize;
  final Uint8List? bytes;

  FileInfo(this.fileName, this.filePath, this.fileSize, {this.bytes});

  factory FileInfo.empty() {
    return FileInfo('', '', 0);
  }

  factory FileInfo.fromBytes({
    required Uint8List bytes,
    String? name,
    int? size
  }) {
    return FileInfo(name ?? '', '', size ?? 0, bytes: bytes);
  }

  String get fileExtension => fileName.split('.').last;

  String get mimeType => lookupMimeType(kIsWeb ? fileName : filePath) ?? 'application/octet-stream';

  @override
  List<Object?> get props => [fileName, filePath, fileSize, bytes];
}