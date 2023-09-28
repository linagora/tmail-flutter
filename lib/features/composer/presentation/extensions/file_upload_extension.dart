import 'dart:convert' as convert;
import 'dart:typed_data' as type_data;

import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:html_editor_enhanced/utils/file_upload_model.dart';
import 'package:model/upload/file_info.dart';

extension FileUploadExtension on FileUpload {

  String? get base64Data {
    if (base64 != null) {
      if (!base64!.contains(',')) {
        return base64;
      }
      final listData = base64!.split(',');
      if (listData.length < 2) {
        return base64;
      }

      final base64Origin = listData[1];
      return base64Origin;
    }
    return base64;
  }

  Future<FileInfo?> toFileInfo() async {
    if (base64Data != null) {
      final bytesStream = await compute(convertBytesToStream, base64Data!);
      return FileInfo.fromStream(
        stream: bytesStream,
        name: name,
        size: size
      );
    } else {
      return null;
    }
  }

  static Stream<List<int>> convertBytesToStream(String base64) {
    type_data.Uint8List decodeBytes = convert.base64Decode(base64);
    final bytesStream = BodyBytesStream.fromBytes(decodeBytes);
    return bytesStream;
  }
}