import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

class FileInfo with EquatableMixin {
  final String fileName;
  final int fileSize;
  final String? filePath;
  final Uint8List? bytes;
  final Stream<List<int>>? readStream;
  final String? type;
  final bool? isInline;
  final bool? isShared;

  FileInfo({
    required this.fileName,
    required this.fileSize,
    this.filePath,
    this.bytes,
    this.readStream,
    this.type,
    this.isInline,
    this.isShared,
  });

  factory FileInfo.fromBytes({
    required Uint8List bytes,
    String? name,
    int? size,
    String? type,
  }) {
    return FileInfo(
      fileName: name ?? '',
      fileSize: size ?? 0,
      bytes: bytes,
      type: type
    );
  }

  String get fileExtension => fileName.split('.').last;

  String get mimeType {
    if (type?.isNotEmpty == true) {
      return type!;
    } else if (filePath?.isNotEmpty == true){
      final matchedType = lookupMimeType(filePath!, headerBytes: bytes) ?? 'application/octet-stream';
      return matchedType;
    } else {
      final matchedType = lookupMimeType(fileName, headerBytes: bytes) ?? 'application/octet-stream';
      return matchedType;
    }
  }

  @override
  List<Object?> get props => [
    fileName,
    filePath,
    fileSize,
    bytes,
    readStream,
    type,
    isInline,
    isShared,
  ];
}