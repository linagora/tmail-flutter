import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mime/mime.dart';

/// A file to attach or upload. The subtype names where its bytes live.
sealed class FileInfo with EquatableMixin {
  final String fileName;
  final int fileSize;
  final String? type;
  final bool? isInline;
  final bool? isShared;

  const FileInfo({
    required this.fileName,
    required this.fileSize,
    this.type,
    this.isInline,
    this.isShared,
  });

  String get fileExtension => fileName.split('.').last;

  String get mimeType => _resolveMimeType(fileName);

  String _resolveMimeType(String lookupPath, {Uint8List? headerBytes}) {
    if (type?.isNotEmpty == true) {
      return type!;
    }
    return lookupMimeType(lookupPath, headerBytes: headerBytes) ?? 'application/octet-stream';
  }

  @override
  List<Object?> get props => [fileName, fileSize, type, isInline, isShared];
}

/// A file on the local file system — mobile picks, shares, compressed images.
final class FilePathInfo extends FileInfo {
  final String filePath;

  const FilePathInfo({
    required super.fileName,
    required super.fileSize,
    required this.filePath,
    super.type,
    super.isInline,
    super.isShared,
  });

  @override
  String get mimeType => _resolveMimeType(filePath.isNotEmpty ? filePath : fileName);

  @override
  List<Object?> get props => [...super.props, filePath];
}

/// A file already in memory — web picks, inline images, decoded base64.
final class FileBytesInfo extends FileInfo {
  final Uint8List bytes;

  FileBytesInfo({
    required this.bytes,
    String? fileName,
    int? fileSize,
    super.type,
    super.isInline,
    super.isShared,
  }) : super(fileName: fileName ?? '', fileSize: fileSize ?? bytes.length);

  @override
  String get mimeType => _resolveMimeType(fileName, headerBytes: bytes);

  @override
  List<Object?> get props => [...super.props, bytes];
}

/// Metadata only, no bytes — e.g. a chip shown before its file is fetched.
final class FilePlaceholderInfo extends FileInfo {
  const FilePlaceholderInfo({
    required super.fileName,
    required super.fileSize,
    super.type,
    super.isInline,
    super.isShared,
  });
}
