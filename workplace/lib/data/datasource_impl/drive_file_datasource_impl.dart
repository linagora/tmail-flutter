import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:model/upload/file_info.dart';
import 'package:workplace/data/datasource/drive_file_datasource.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveFileDatasourceImpl implements DriveFileDatasource {
  final Dio _dio;

  DriveFileDatasourceImpl({Dio? dio}) : _dio = dio ?? WorkplaceDio.instance;

  @override
  Future<FileInfo> downloadFile(DriveDocument doc) async {
    final response = await _dio.get<List<int>>(
      doc.downloadLink!.toString(),
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null) throw Exception('No data received for ${doc.name}');
    return FileInfo(
      fileName: doc.name,
      fileSize: doc.size,
      bytes: Uint8List.fromList(data),
      type: doc.mimeType,
    );
  }
}
