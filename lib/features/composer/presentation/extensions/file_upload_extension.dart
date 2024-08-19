import 'dart:convert' as convert;
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

  FileInfo? toFileInfo() {
    if (base64Data != null) {
      return FileInfo.fromBytes(
        bytes: convert.base64Decode(base64Data!),
        name: name,
        size: size,
        type: type,
        isInline: true
      );
    } else {
      return null;
    }
  }
}