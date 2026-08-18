import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

abstract class UploadFromUrlRepository {
  Future<Attachment> uploadFromUrl(UploadFromUrlRequest request);
}
