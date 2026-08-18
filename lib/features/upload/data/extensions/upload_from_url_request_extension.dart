import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

extension UploadFromUrlRequestExtension on UploadFromUrlRequest {
  String get uploadApiPath => '/upload-from-url/${accountId.id.value}';

  Map<String, dynamic> get uploadPayload => {
        'url': downloadLink.toString(),
        'name': name,
        'type': mimeType,
      };
}
