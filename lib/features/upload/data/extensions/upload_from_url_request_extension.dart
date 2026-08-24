import 'dart:io';

import 'package:core/data/constants/constant.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

extension UploadFromUrlRequestExtension on UploadFromUrlRequest {
  // BE reads the source URL and mime type from headers, not a JSON body.
  Map<String, dynamic> get uploadHeaders => {
        HttpHeaders.contentTypeHeader:
            mimeType.trim().isEmpty ? Constant.octetStreamMimeType : mimeType.trim(),
        HttpHeaders.contentLocationHeader: attachmentUrl.toString(),
      };
}
