
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:model/model.dart';

class ComposerAPI {

  final DioClient _dioClient;

  ComposerAPI(this._dioClient);

  Future<UploadResponse> uploadAttachment(UploadRequest uploadRequest) async {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.contentTypeHeader] = uploadRequest.fileInfo.mimeType;
    headerParam[HttpHeaders.contentLengthHeader] = uploadRequest.fileInfo.fileSize;

    final resultJson = await _dioClient.post(
        Uri.decodeFull(uploadRequest.uploadUrl.toString()),
        options: Options(headers: headerParam),
        data: uploadRequest.fileInfo.readStream);

    final decodeJson = resultJson is Map ? resultJson : jsonDecode(resultJson);

    return UploadResponse.fromJson(decodeJson);
  }
}