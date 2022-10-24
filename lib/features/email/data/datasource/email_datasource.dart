import 'dart:async';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';

abstract class EmailDataSource {
  Future<Email> getEmailContent(AccountId accountId, EmailId emailId);

  Future<bool> sendEmail(AccountId accountId, EmailRequest emailRequest, {CreateNewMailboxRequest? mailboxRequest});

  Future<List<Email>> markAsRead(AccountId accountId, List<Email> emails, ReadActions readActions);

  Future<List<DownloadTaskId>> downloadAttachments(
    List<Attachment> attachments,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest
  );

  Future<DownloadedResponse> exportAttachment(
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    CancelToken cancelToken
  );

  Future<Uint8List> downloadAttachmentForWeb(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    StreamController<Either<Failure, Success>> onReceiveController
  );

  Future<List<EmailId>> moveToMailbox(AccountId accountId, MoveToMailboxRequest moveRequest);

  Future<List<Email>> markAsStar(
    AccountId accountId,
    List<Email> emails,
    MarkStarAction markStarAction
  );

  Future<Email?> saveEmailAsDrafts(AccountId accountId, Email email);

  Future<bool> removeEmailDrafts(AccountId accountId, EmailId emailId);

  Future<Email?> updateEmailDrafts(AccountId accountId, Email newEmail, EmailId oldEmailId);

  Future<List<EmailId>> deleteMultipleEmailsPermanently(AccountId accountId, List<EmailId> emailIds);

  Future<bool> deleteEmailPermanently(AccountId accountId, EmailId emailId);
}