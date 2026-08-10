import 'package:core/utils/build_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
class BufferedWebDriveFileStager implements DriveFileStager<BytesStagedFile> {
  BufferedWebDriveFileStager({Dio? dio, bool? isReleaseMode})
      : _dio = dio ?? WorkplaceDio.instance,
        _isReleaseMode = isReleaseMode ?? BuildUtils.isReleaseMode;

  final Dio _dio;
  final bool _isReleaseMode;

  @override
  Future<BytesStagedFile> stage({
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
class BufferedWebDriveTransferStrategy
    extends DriveTransferStrategy<BytesStagedFile> {
  BufferedWebDriveTransferStrategy({
    required StagedFileUploader uploader,
    DriveFileStager<BytesStagedFile>? stager,
  })  : _uploader = uploader,
        _stager = stager ?? BufferedWebDriveFileStager();

  final StagedFileUploader _uploader;
  final DriveFileStager<BytesStagedFile> _stager;

  @protected
  @override
  Future<BytesStagedFile> stage({
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

  /// `request.authHeader` is unused: the shared uploader authenticates
  /// through the app's Dio interceptors. Only the OPFS raw-XHR path needs it.
  @protected
  @override
  Future<Attachment> upload(DriveUploadRequest<BytesStagedFile> request) {
    return _uploader(
      staged: request.staged,
      uploadUri: request.uploadUri,
      onUploadProgress: request.onUploadProgress,
      cancelToken: request.cancelToken,
    );
  }
}
