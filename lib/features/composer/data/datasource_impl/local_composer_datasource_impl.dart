import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:model/upload/upload_request.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/local/email_address_database_manager.dart';

class LocalComposerDataSourceImpl extends ComposerDataSource {

  final EmailAddressDatabaseManager emailAddressDatabaseManager;

  LocalComposerDataSourceImpl(this.emailAddressDatabaseManager);

  @override
  Future<bool> saveEmailAddresses(List<EmailAddress> listEmailAddress) {
    return Future.sync(() async {
      return await emailAddressDatabaseManager.insertMultipleData(listEmailAddress);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<Attachment> uploadAttachment(UploadRequest uploadRequest) {
    throw UnimplementedError();
  }
}