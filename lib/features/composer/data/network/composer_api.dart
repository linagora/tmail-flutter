
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:model/model.dart';

class ComposerAPI {

  final DioClient _dioClient;

  ComposerAPI(this._dioClient);

  Future<UploadResponse> uploadAttachment(UploadRequest uploadRequest) async {
    final file = File(uploadRequest.fileInfo.filePath);
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.contentTypeHeader] = uploadRequest.fileInfo.mimeType;
    headerParam[HttpHeaders.contentLengthHeader] = file.readAsBytesSync().length;

    final resultJson = await _dioClient.post(
        Uri.decodeFull(uploadRequest.uploadUrl.toString()),
        options: Options(headers: headerParam),
        data: file.openRead());
    return UploadResponse.fromJson(jsonDecode(resultJson));
  }
}