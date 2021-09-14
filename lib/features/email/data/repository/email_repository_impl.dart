
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';

class EmailRepositoryImpl extends EmailRepository {

  final EmailDataSource emailDataSource;

  EmailRepositoryImpl(this.emailDataSource);

  @override
  Future<Email> getEmailContent(AccountId accountId, EmailId emailId) {
    return emailDataSource.getEmailContent(accountId, emailId);
  }

  @override
  Future<bool> sendEmail(AccountId accountId, EmailRequest emailRequest) {
    return emailDataSource.sendEmail(accountId, emailRequest);
  }

  @override
  Future<bool> markAsRead(AccountId accountId, EmailId emailId, bool unread) {
    return emailDataSource.markAsRead(accountId, emailId, unread);
  }
}