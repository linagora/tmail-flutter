
import 'dart:io';

import 'package:core/core.dart';
import 'package:model/model.dart';

class ComposerAPI {

  final DioClient _dioClient;

  ComposerAPI(this._dioClient);

  Future<UploadResponse> uploadAttachment(UploadRequest uploadRequest) async {
    final resultJson = await _dioClient.post(
        Uri.decodeFull(uploadRequest.uploadUrl.toString()),
        data: File(uploadRequest.fileInfo.filePath).readAsBytesSync());
    return UploadResponse.fromJson(resultJson);
  }
}