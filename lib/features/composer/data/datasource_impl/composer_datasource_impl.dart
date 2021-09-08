import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';

class ComposerDataSourceImpl extends ComposerDataSource {

  ComposerDataSourceImpl();

  @override
  Future<bool> saveEmailAddresses(List<EmailAddress> listEmailAddress) {
    throw UnimplementedError();
  }
}