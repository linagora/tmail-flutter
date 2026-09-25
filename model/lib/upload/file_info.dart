import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mime/mime.dart';

/// Opens a fresh stream over a file's bytes, bounded by [start]/[end].
typedef FileOpenRead = Stream<List<int>> Function([int? start, int? end]);

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

  /// A fresh stream over the bytes on every call, like [File.openRead] — so a 401
  /// replay re-reads the source instead of a drained stream.
  Stream<List<int>> openRead([int? start, int? end]);

  /// Reads the whole file into memory. Only for small inline content —
  /// an attachment is streamed instead, never collected like this.
  Future<Uint8List> readBytes() async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in openRead()) {
      builder.add(chunk);
    }
    return builder.takeBytes();
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
  Stream<List<int>> openRead([int? start, int? end]) => File(filePath).openRead(start, end);

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
  Stream<List<int>> openRead([int? start, int? end]) {
    final from = start ?? 0;
    if (from < 0) return Stream<List<int>>.error(RangeError('Bad start position: $from'));
    if (end != null && end < from) return Stream<List<int>>.error(RangeError('Bad end position: $end'));
    final to = min(end ?? bytes.length, bytes.length);
    if (from >= to) return const Stream<List<int>>.empty();
    return Stream<List<int>>.value(from == 0 && to == bytes.length ? bytes : bytes.sublist(from, to));
  }

  @override
  Future<Uint8List> readBytes() async => bytes;

  @override
  List<Object?> get props => [...super.props, bytes];
}

/// A browser file behind a `blob:` URL — web picks and drops. [sourceUrl] lets an
/// upload hand the blob straight to the request instead of reading it.
final class FileBlobInfo extends FileInfo {
  /// Not part of equality — two picks of the same file mint different URLs.
  final String sourceUrl;
  final FileOpenRead _openRead;

  const FileBlobInfo({
    required super.fileName,
    required super.fileSize,
    required this.sourceUrl,
    required FileOpenRead openRead,
    super.type,
    super.isInline,
    super.isShared,
  }) : _openRead = openRead;

  @override
  Stream<List<int>> openRead([int? start, int? end]) => _openRead(start, end);
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

  @override
  Stream<List<int>> openRead([int? start, int? end]) =>
      throw StateError('No readable byte source for $fileName');
}
