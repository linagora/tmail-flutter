import 'dart:convert';

import 'package:dio/dio.dart';
import '../model/workplace_enums.dart';
import '../model/workplace_file_response.dart';
import 'workplace_request_executor.dart';
import '../../domain/entity/drive_uploaded_file.dart';
import '../../domain/entity/workplace_upload_file_spec.dart';

/// Writes a file to the Mail magic folder.
/// Split out of `WorkplaceDataSourceImpl` to keep that file under 200 lines.
class WorkplaceDriveFileGateway {
  const WorkplaceDriveFileGateway(this._executor);

  final WorkplaceRequestExecutor _executor;

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw FormatException('Expected JSON object or string, got: ${data.runtimeType}');
  }

  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceRequestTransfer transfer = const WorkplaceRequestTransfer(),
  }) async {
    try {
      return await _uploadOnce(context, spec.fileName, spec, transfer);
    } on DioException catch (exception) {
      // The stack already holds a file by that name; one retry with a suffix.
      if (exception.response?.statusCode != 409) rethrow;
      return _uploadOnce(context, _suffixedName(spec.fileName), spec, transfer);
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

  /// `report.pdf` → `report (1).pdf`; an extension-less name gets the suffix appended.
  static String _suffixedName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0) return '$fileName (1)';
    return '${fileName.substring(0, dot)} (1)${fileName.substring(dot)}';
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
