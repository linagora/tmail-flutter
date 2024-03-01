import 'dart:convert' as convert;
import 'dart:typed_data' as type_data;

import 'package:flutter/foundation.dart';
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
      final bytes = await compute(convertBase64ToBytes, base64Data!);
      return FileInfo.fromBytes(
        bytes: bytes,
        name: name,
        size: size,
        type: type,
      );
    } else {
      return null;
    }
  }

  static Uint8List convertBase64ToBytes(String base64) {
    type_data.Uint8List decodeBytes = convert.base64Decode(base64);
    return decodeBytes;
  }
}