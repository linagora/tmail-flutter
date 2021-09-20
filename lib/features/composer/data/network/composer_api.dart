
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:model/model.dart';

class ComposerAPI {

  final DioClient _dioClient;

  ComposerAPI(this._dioClient);

  Future<UploadResponse> uploadAttachment(UploadRequest uploadRequest) async {
    final resultJson = await _dioClient.post(
        Uri.decodeFull(uploadRequest.uploadUrl.toString()),
        options: Options(headers: _buildHeaderRequestParam()),
        data: File(uploadRequest.fileInfo.filePath).readAsBytesSync());
    return UploadResponse.fromJson(resultJson);
  }

  Map<String, dynamic> _buildHeaderRequestParam() {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.acceptHeader] = DioClient.jmapHeader;
    return headerParam;
  }
}