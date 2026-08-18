import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

abstract class UploadFromUrlDataSource {
  Future<UploadResponse> uploadFromUrl(UploadFromUrlRequest request);
}
