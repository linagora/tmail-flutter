import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';

class EmailDataSourceImpl extends EmailDataSource {

  final EmailAPI emailAPI;

  EmailDataSourceImpl(this.emailAPI);

  @override
  Future<Email> getEmailContent(AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      return await emailAPI.getEmailContent(accountId, emailId);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> sendEmail(AccountId accountId, EmailRequest emailRequest) {
    return Future.sync(() async {
      return await emailAPI.sendEmail(accountId, emailRequest);
    }).catchError((error) {
      throw error;
    });
  }
}