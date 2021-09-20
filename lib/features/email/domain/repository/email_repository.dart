import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';

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

  Future<List<EmailId>> moveToMailbox(AccountId accountId, MoveRequest moveRequest);

  Future<bool> markAsImportant(AccountId accountId, EmailId emailId, ImportantAction importantAction);
  Future<List<Email>> markAsStar(
    AccountId accountId,
    List<Email> emails,
    MarkStarAction markStarAction
  );
}