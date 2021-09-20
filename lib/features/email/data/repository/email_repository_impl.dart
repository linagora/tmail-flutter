
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';
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
  Future<List<Email>> markAsRead(AccountId accountId, List<Email> emails, ReadActions readActions) {
    return emailDataSource.markAsRead(accountId, emails, readActions);
  }

  @override
  Future<List<DownloadTaskId>> downloadAttachments(
      List<Attachment> attachments,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest
  ) {
    return emailDataSource.downloadAttachments(attachments, accountId, baseDownloadUrl, accountRequest);
  }

  @override
  Future<String> exportAttachment(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      CancelToken cancelToken
  ) {
    return emailDataSource.exportAttachment(
      attachment,
      accountId,
      baseDownloadUrl,
      accountRequest,
      cancelToken);
  }

  @override
  Future<List<EmailId>> moveToMailbox(AccountId accountId, MoveRequest moveRequest) {
    return emailDataSource.moveToMailbox(accountId, moveRequest);
  }

  @override
  Future<bool> markAsImportant(AccountId accountId, EmailId emailId, ImportantAction importantAction) {
    return emailDataSource.markAsImportant(accountId, emailId, importantAction);
  }
}