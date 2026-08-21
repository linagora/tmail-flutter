import 'package:model/email/attachment.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/upload_from_url_datasource.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_from_url_account_mismatch_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_repository.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

class UploadFromUrlRepositoryImpl implements UploadFromUrlRepository {
  final UploadFromUrlDataSource _uploadFromUrlDataSource;

  const UploadFromUrlRepositoryImpl(this._uploadFromUrlDataSource);

  @override
  Future<Attachment> uploadFromUrl(UploadFromUrlRequest request) async {
    final uploadResponse = await _uploadFromUrlDataSource.uploadFromUrl(request);
    if (uploadResponse.accountId != request.accountId) {
      throw UploadFromUrlAccountMismatchException();
    }
    return uploadResponse.toAttachment(nameFile: request.name);
  }
}
