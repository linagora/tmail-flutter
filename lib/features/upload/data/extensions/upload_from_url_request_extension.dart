import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

extension UploadFromUrlRequestExtension on UploadFromUrlRequest {
  Map<String, dynamic> get uploadPayload => {
        'url': attachmentUrl.toString(),
        'name': name,
        'type': mimeType,
      };
}
