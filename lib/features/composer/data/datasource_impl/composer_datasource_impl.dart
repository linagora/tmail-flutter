import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/network/composer_api.dart';

class ComposerDataSourceImpl extends ComposerDataSource {

  final ComposerAPI _composerAPI;

  ComposerDataSourceImpl(this._composerAPI);

  @override
  Future<bool> saveEmailAddresses(List<EmailAddress> listEmailAddress) {
    throw UnimplementedError();
  }

  @override
  Future<Attachment> uploadAttachment(UploadRequest uploadRequest) {
    return Future.sync(() async {
      final uploadResponse = await _composerAPI.uploadAttachment(uploadRequest);
      return uploadResponse.toAttachmentFile(uploadRequest.fileInfo.fileName);
    }).catchError((error) {
      throw error;
    });
  }
}