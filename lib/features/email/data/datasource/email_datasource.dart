import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';

abstract class EmailDataSource {
  Future<Email> getEmailContent(AccountId accountId, EmailId emailId);

  Future<bool> sendEmail(AccountId accountId, EmailRequest emailRequest);

  Future<bool> markAsRead(AccountId accountId, EmailId emailId, ReadActions readActions);
}