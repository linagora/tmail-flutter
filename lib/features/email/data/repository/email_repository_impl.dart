
import 'dart:async';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';

class EmailRepositoryImpl extends EmailRepository {

  final EmailDataSource emailDataSource;
  final HtmlDataSource _htmlDataSource;
  final StateDataSource _stateDataSource;

  EmailRepositoryImpl(
    this.emailDataSource,
    this._htmlDataSource,
    this._stateDataSource
  );

  @override
  Future<Email> getEmailContent(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource.getEmailContent(session ,accountId, emailId);
  }

  @override
  Future<bool> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {CreateNewMailboxRequest? mailboxRequest}
  ) {
    return emailDataSource.sendEmail(session, accountId, emailRequest, mailboxRequest: mailboxRequest);
  }

  @override
  Future<List<Email>> markAsRead(
    Session session,
    AccountId accountId,
    List<Email> emails,
    ReadActions readActions
  ) {
    return emailDataSource.markAsRead(session, accountId, emails, readActions);
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
  Future<DownloadedResponse> exportAttachment(
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
  Future<List<EmailId>> moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    return emailDataSource.moveToMailbox(session, accountId, moveRequest);
  }

  @override
  Future<List<Email>> markAsStar(
    Session session,
    AccountId accountId,
    List<Email> emails,
    MarkStarAction markStarAction
  ) {
    return emailDataSource.markAsStar(session, accountId, emails, markStarAction);
  }

  @override
  Future<List<EmailContent>> transformEmailContent(
      List<EmailContent> emailContents,
      List<Attachment> attachmentInlines,
      String? baseUrlDownload,
      AccountId accountId,
      {bool draftsEmail = false}
    ) async {
    final mapUrlDownloadCID = {
      for (var attachment in attachmentInlines)
        attachment.cid! : attachment.getDownloadUrl(baseUrlDownload!, accountId)
    };
    return await Future.wait(emailContents
      .map((emailContent) async {
        return await _htmlDataSource.transformEmailContent(
          emailContent,
          mapUrlDownloadCID,
          draftsEmail: draftsEmail
        );
      })
      .toList());
  }

  @override
  Future<Email> saveEmailAsDrafts(Session session, AccountId accountId, Email email) {
    return emailDataSource.saveEmailAsDrafts(session, accountId, email);
  }

  @override
  Future<bool> removeEmailDrafts(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource.removeEmailDrafts(session, accountId, emailId);
  }

  @override
  Future<Email> updateEmailDrafts(Session session, AccountId accountId, Email newEmail) {
    return emailDataSource.updateEmailDrafts(session, accountId, newEmail);
  }

  @override
  Future<Uint8List> downloadAttachmentForWeb(
      DownloadTaskId taskId,
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      StreamController<Either<Failure, Success>> onReceiveController
  ) {
    return emailDataSource.downloadAttachmentForWeb(
        taskId,
        attachment,
        accountId,
        baseDownloadUrl,
        accountRequest,
        onReceiveController);
  }

  @override
  Future<List<EmailId>> deleteMultipleEmailsPermanently(Session session, AccountId accountId, List<EmailId> emailIds) {
    return emailDataSource.deleteMultipleEmailsPermanently(session, accountId, emailIds);
  }

  @override
  Future<bool> deleteEmailPermanently(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource.deleteEmailPermanently(session, accountId, emailId);
  }

  @override
  Future<List<EmailContent>> addTooltipWhenHoverOnLink(List<EmailContent> emailContents) {
    return Future.wait(emailContents
      .map((emailContent) => _htmlDataSource.addTooltipWhenHoverOnLink(emailContent))
      .toList());
  }

  @override
  Future<jmap.State?> getEmailState() {
    return _stateDataSource.getState(StateType.email);
  }
}