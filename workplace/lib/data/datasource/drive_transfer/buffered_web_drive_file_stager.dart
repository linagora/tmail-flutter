import 'dart:typed_data';

import 'package:core/utils/build_utils.dart';
import 'package:dio/dio.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

/// Buffers a drive document fully into memory. Explicit, feature-detected
/// fallback for browsers without OPFS `createWritable()` support — checked
/// (the actual-byte guard still cancels on breach), not memory-flat.
class BufferedWebDriveFileStager implements DriveFileStager {
  BufferedWebDriveFileStager({Dio? dio, bool? isReleaseMode})
      : _dio = dio ?? WorkplaceDio.instance,
        _isReleaseMode = isReleaseMode ?? BuildUtils.isReleaseMode;

  final Dio _dio;
  final bool _isReleaseMode;

  @override
  Future<StagedDriveFile> stage({
    required DriveDocument doc,
    required void Function(int received, int total) onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    final downloadLink = doc.downloadLink;
    if (downloadLink == null) {
      throw DriveDownloadNullAttachmentException();
    }
    if (_isReleaseMode && !downloadLink.isScheme('https')) {
      throw DriveDownloadInsecureLinkException();
    }
    final response = await _dio.getUri<List<int>>(
      downloadLink,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: driveTransferReceiveTimeout,
      ),
      cancelToken: cancelToken,
      onReceiveProgress: onDownloadProgress,
    );

    final data = response.data;
    if (data == null) {
      throw DriveDownloadEmptyResponseException();
    }
    final bytes = data is Uint8List ? data : Uint8List.fromList(data);
    return BytesStagedFile(
      bytes: bytes,
      fileName: doc.name,
      fileSize: bytes.length,
      mimeType: doc.mimeType,
    );
  }
}

/// Web-buffered strategy: no OPFS-only uploader, `FileUploader` handles the
/// bytes-backed upload leg.
class BufferedWebDriveTransferStrategy implements DriveTransferStrategy {
  @override
  final DriveFileStager stager;

  @override
  OpfsDriveFileUploader? get opfsUploader => null;

  BufferedWebDriveTransferStrategy({DriveFileStager? stager})
      : stager = stager ?? BufferedWebDriveFileStager();
}
