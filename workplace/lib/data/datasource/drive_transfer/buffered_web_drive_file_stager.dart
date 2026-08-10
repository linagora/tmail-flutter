import 'dart:typed_data';

import 'package:core/utils/build_utils.dart';
import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/drive_document_extension.dart';
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
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    final downloadLink =
        doc.resolveDownloadLinkForStaging(isReleaseMode: _isReleaseMode);
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

/// Web-buffered strategy: buffers the download in memory, then uploads the
/// bytes-backed staged file through the injected uploader.
class BufferedWebDriveTransferStrategy implements DriveTransferStrategy {
  BufferedWebDriveTransferStrategy({
    required StagedFileUploader uploader,
    DriveFileStager? stager,
  })  : _uploader = uploader,
        _stager = stager ?? BufferedWebDriveFileStager();

  final StagedFileUploader _uploader;
  final DriveFileStager _stager;

  @override
  Future<StagedDriveFile> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  }) {
    return _stager.stage(
      doc: doc,
      onDownloadProgress: onDownloadProgress,
      cancelToken: cancelToken,
    );
  }

  /// [authHeader] is unused: the shared uploader authenticates through the
  /// app's Dio interceptors. Only the OPFS raw-XHR path needs it.
  @override
  Future<Attachment> upload({
    required StagedDriveFile staged,
    required Uri uploadUri,
    required String authHeader,
    required OnFileProcessedProgress onUploadProgress,
    required CancelToken cancelToken,
  }) {
    return _uploader(
      staged: staged,
      uploadUri: uploadUri,
      onUploadProgress: onUploadProgress,
      cancelToken: cancelToken,
    );
  }
}
