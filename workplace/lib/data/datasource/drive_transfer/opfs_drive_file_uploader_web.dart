import 'dart:async';

import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/upload_response.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';

/// Web-only implementation of [OpfsDriveFileUploader]. Only ever constructed
/// from the web branch of `DriveTransferStrategyFactory`, so this file (and
/// its `package:web` import) never enters an IO/mobile build.
class BrowserOpfsDriveFileUploader implements OpfsDriveFileUploader {
  final OpfsJsBindings _bindings;

  BrowserOpfsDriveFileUploader({OpfsJsBindings? bindings})
      : _bindings = bindings ?? OpfsJsBindings.instance;

  @override
  Future<Attachment> upload(OpfsUploadRequest request) async {
    _throwIfCancelled(request.cancelToken);
    final file = await _bindings.getFile(request.fileHandle);
    _throwIfCancelled(request.cancelToken);

    final upload = _bindings.uploadFile(XhrUploadFileRequest(
      file: file,
      uploadUri: request.uploadUri,
      authHeader: request.authHeader,
      onUploadProgress: request.onUploadProgress,
    ));

    final cancelSubscription =
        request.cancelToken.whenCancel.then((_) => upload.abort());
    try {
      final json = await upload.response;
      final uploadResponse = UploadResponse.fromJson(json);
      return uploadResponse.toAttachment(
          nameFile: request.fileName, charset: null);
    } finally {
      unawaited(cancelSubscription);
    }
  }

  void _throwIfCancelled(CancelToken cancelToken) {
    if (cancelToken.isCancelled) {
      throw cancelToken.cancelError!;
    }
  }
}
