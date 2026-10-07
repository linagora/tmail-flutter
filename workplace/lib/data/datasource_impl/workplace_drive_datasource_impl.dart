import 'dart:convert';

import 'package:dio/dio.dart';
import '../model/workplace_enums.dart';
import '../model/workplace_file_response.dart';
import '../datasource/workplace_drive_datasource.dart';
import 'workplace_request_executor.dart';
import '../../domain/entity/drive_uploaded_file.dart';
import '../../domain/entity/workplace_upload_file_spec.dart';
import '../../domain/entity/workplace_upload_transfer.dart';

/// Writes a file to the Mail magic folder.
class WorkplaceDriveDataSourceImpl implements WorkplaceDriveDataSource {
  WorkplaceDriveDataSourceImpl({WorkplaceRequestExecutor? executor})
      : _executor = executor ?? const WorkplaceRequestExecutor();

  final WorkplaceRequestExecutor _executor;

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw FormatException('Expected JSON object or string, got: ${data.runtimeType}');
  }

  /// Name-taken attempts before the 409 surfaces; each one re-sends the body.
  static const _maxNameAttempts = 10;

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) async {
    final requestTransfer = _toRequestTransfer(transfer);
    for (var attempt = 0;; attempt++) {
      try {
        return await _uploadOnce(context, _nameFor(spec.fileName, attempt), spec, requestTransfer);
      } on DioException catch (exception) {
        // The stack already holds a file by that name; retry with the next suffix.
        final isLast = attempt + 1 >= _maxNameAttempts;
        if (exception.response?.statusCode != 409 || isLast) rethrow;
      }
    }
  }

  Future<DriveUploadedFile> _uploadOnce(
    WorkplaceRequestContext context,
    String name,
    WorkplaceUploadFileSpec spec,
    WorkplaceRequestTransfer transfer,
  ) async {
    final data = await _executor.send(
      context: context,
      route: WorkplaceRequestRoute(
        method: 'POST',
        // `:dir-id` is the magic-folder id; the executor encodes its '/' as %2F.
        pathSegments: ['files', WorkplaceMagicFolder.mail.value],
        queryParameters: {
          'Type': WorkplaceUploadType.file.value,
          'Name': name,
        },
      ),
      body: WorkplaceRequestBody(
        data: spec.source.requestData,
        headers: {'Content-Type': spec.mimeType, 'Content-Length': '${spec.fileSize}'},
        extra: spec.source.dioExtra,
      ),
      transfer: transfer,
    );
    return _parseUploadedFile(data);
  }

  static WorkplaceRequestTransfer _toRequestTransfer(WorkplaceUploadTransfer transfer) {
    final signal = transfer.cancelSignal;
    final cancelToken = signal == null ? null : CancelToken();
    // A failed signal cancels too; neither path leaves an unhandled error.
    signal?.then((_) => cancelToken!.cancel(), onError: (_) => cancelToken!.cancel());
    return WorkplaceRequestTransfer(
      onSendProgress: transfer.onProgress,
      cancelToken: cancelToken,
      timeout: transfer.timeout,
    );
  }

  /// Attempt 0 keeps the name; then `report.pdf` → `report (n).pdf`, extension-less gets it appended.
  static String _nameFor(String fileName, int attempt) {
    if (attempt == 0) return fileName;
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0) return '$fileName ($attempt)';
    return '${fileName.substring(0, dot)} ($attempt)${fileName.substring(dot)}';
  }

  DriveUploadedFile _parseUploadedFile(dynamic data) {
    final parsed = WorkplaceFileResponse.fromJson(_asJsonMap(data));
    final doc = parsed.data;
    if (doc.id.isEmpty) {
      throw StateError('Upload response contains no file id');
    }
    return DriveUploadedFile(fileId: doc.id, name: doc.attributes?.name ?? '');
  }
}
