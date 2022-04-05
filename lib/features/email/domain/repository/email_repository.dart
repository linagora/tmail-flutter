import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_trash_request.dart';

abstract class EmailRepository {
  Future<Email> getEmailContent(AccountId accountId, EmailId emailId);

  Future<bool> sendEmail(AccountId accountId, EmailRequest emailRequest);

  Future<List<Email>> markAsRead(AccountId accountId, List<Email> emails, ReadActions readActions);

  Future<List<DownloadTaskId>> downloadAttachments(
    List<Attachment> attachments,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest
  );

  Future<String> exportAttachment(
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    CancelToken cancelToken
  );

  Future<bool> downloadAttachmentForWeb(
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
  );

  Future<List<EmailId>> moveToMailbox(AccountId accountId, MoveRequest moveRequest);

  Future<List<EmailId>> moveToTrash(AccountId accountId, MoveToTrashRequest moveRequest);

  Future<List<Email>> markAsStar(
    AccountId accountId,
    List<Email> emails,
    MarkStarAction markStarAction
  );

  Future<List<EmailContent>> transformEmailContent(
    List<EmailContent> emailContents,
    List<Attachment> attachmentInlines,
    String? baseUrlDownload,
    AccountId accountId
  );

  Future<Email?> saveEmailAsDrafts(AccountId accountId, Email email);

  Future<bool> removeEmailDrafts(AccountId accountId, EmailId emailId);

  Future<Email?> updateEmailDrafts(AccountId accountId, Email newEmail, EmailId oldEmailId);

  Future<List<EmailId>> deleteMultipleEmailPermanently(Session session, AccountId accountId, List<EmailId> emailIds);
}