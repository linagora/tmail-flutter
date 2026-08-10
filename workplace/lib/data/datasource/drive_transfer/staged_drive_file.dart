import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';

/// Result of staging a drive document into platform-appropriate temp storage,
/// ready to be uploaded. One variant per platform capability.
///
/// Variants inject their [dispose] logic rather than importing `dart:io` or
/// `dart:js_interop` here, so this file stays compilable on every platform.
sealed class StagedDriveFile extends Equatable {
  final String fileName;
  final int fileSize;
  final String? mimeType;

  const StagedDriveFile({
    required this.fileName,
    required this.fileSize,
    this.mimeType,
  });

  /// Removes the underlying temp storage (disk file or OPFS entry).
  /// No-op for in-memory staged files. Safe to call on every exit path.
  Future<void> dispose();
}

/// IO temp file (mobile/desktop).
final class FileBackedStagedFile extends StagedDriveFile {
  final String filePath;
  final OnDeleteIOFile deleteFile;

  const FileBackedStagedFile({
    required this.filePath,
    required this.deleteFile,
    required super.fileName,
    required super.fileSize,
    super.mimeType,
  });

  @override
  Future<void> dispose() => deleteFile(filePath);

  @override
  List<Object?> get props => [filePath, fileName, fileSize, mimeType];
}

/// Web, Origin Private File System temp file handle.
final class OpfsStagedFile extends StagedDriveFile {
  final OpfsFileHandle fileHandle;
  final OnDeleteOPFSFile removeEntry;

  const OpfsStagedFile({
    required this.fileHandle,
    required this.removeEntry,
    required super.fileName,
    required super.fileSize,
    super.mimeType,
  });

  @override
  Future<void> dispose() => removeEntry(fileHandle);

  @override
  List<Object?> get props => [fileHandle, fileName, fileSize, mimeType];
}

/// Web, buffered fallback when OPFS is unavailable.
final class BytesStagedFile extends StagedDriveFile {
  final Uint8List bytes;

  const BytesStagedFile({
    required this.bytes,
    required super.fileName,
    required super.fileSize,
    super.mimeType,
  });

  @override
  Future<void> dispose() async {}

  /// Compares [bytes] by identity, not content — value equality over a
  /// potentially large in-memory buffer would make `==`/`hashCode` O(file
  /// size).
  @override
  List<Object?> get props => [
        identityHashCode(bytes),
        fileName,
        fileSize,
        mimeType,
      ];
}
