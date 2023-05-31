
import 'dart:async';
import 'dart:typed_data';

import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';

class EmailRepositoryImpl extends EmailRepository {

  final Map<DataSourceType, EmailDataSource> emailDataSource;
  final HtmlDataSource _htmlDataSource;
  final StateDataSource _stateDataSource;

  EmailRepositoryImpl(
    this.emailDataSource,
    this._htmlDataSource,
    this._stateDataSource
  );

  @override
  Future<Email> getEmailContent(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.network]!.getEmailContent(session ,accountId, emailId);
  }

  @override
  Future<bool> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {CreateNewMailboxRequest? mailboxRequest}
  ) {
    return emailDataSource[DataSourceType.network]!.sendEmail(session, accountId, emailRequest, mailboxRequest: mailboxRequest);
  }

  @override
  Future<List<Email>> markAsRead(
    Session session,
    AccountId accountId,
    List<Email> emails,
    ReadActions readActions
  ) {
    return emailDataSource[DataSourceType.network]!.markAsRead(session, accountId, emails, readActions);
  }

  @override
  Future<List<DownloadTaskId>> downloadAttachments(
      List<Attachment> attachments,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest
  ) {
    return emailDataSource[DataSourceType.network]!.downloadAttachments(attachments, accountId, baseDownloadUrl, accountRequest);
  }

  @override
  Future<DownloadedResponse> exportAttachment(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      CancelToken cancelToken
  ) {
    return emailDataSource[DataSourceType.network]!.exportAttachment(
      attachment,
      accountId,
      baseDownloadUrl,
      accountRequest,
      cancelToken);
  }

  @override
  Future<List<EmailId>> moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    return emailDataSource[DataSourceType.network]!.moveToMailbox(session, accountId, moveRequest);
  }

  @override
  Future<List<Email>> markAsStar(
    Session session,
    AccountId accountId,
    List<Email> emails,
    MarkStarAction markStarAction
  ) {
    return emailDataSource[DataSourceType.network]!.markAsStar(session, accountId, emails, markStarAction);
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
    return emailDataSource[DataSourceType.network]!.saveEmailAsDrafts(session, accountId, email);
  }

  @override
  Future<bool> removeEmailDrafts(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.network]!.removeEmailDrafts(session, accountId, emailId);
  }

  @override
  Future<Email> updateEmailDrafts(Session session, AccountId accountId, Email newEmail) {
    return emailDataSource[DataSourceType.network]!.updateEmailDrafts(session, accountId, newEmail);
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
    return emailDataSource[DataSourceType.network]!.downloadAttachmentForWeb(
        taskId,
        attachment,
        accountId,
        baseDownloadUrl,
        accountRequest,
        onReceiveController);
  }

  @override
  Future<List<EmailId>> deleteMultipleEmailsPermanently(Session session, AccountId accountId, List<EmailId> emailIds) {
    return emailDataSource[DataSourceType.network]!.deleteMultipleEmailsPermanently(session, accountId, emailIds);
  }

  @override
  Future<bool> deleteEmailPermanently(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.network]!.deleteEmailPermanently(session, accountId, emailId);
  }

  @override
  Future<List<EmailContent>> addTooltipWhenHoverOnLink(List<EmailContent> emailContents) {
    return Future.wait(emailContents
      .map((emailContent) => _htmlDataSource.addTooltipWhenHoverOnLink(emailContent))
      .toList());
  }

  @override
  Future<jmap.State?> getEmailState(Session session, AccountId accountId) {
    return _stateDataSource.getState(accountId, session.username, StateType.email);
  }

  @override
  Future<void> storeDetailedEmailToCache(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return emailDataSource[DataSourceType.hiveCache]!.storeDetailedEmail(session, accountId, detailedEmail);
  }

  @override
  Future<Email> getDetailedEmailById(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.network]!.getDetailedEmailById(session, accountId, emailId);
  }

  @override
  Future<void> storeEmailToCache(Session session, AccountId accountId, Email email) {
    return emailDataSource[DataSourceType.hiveCache]!.storeEmail(session, accountId, email);
  }

  @override
  Future<void> storeOpenedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return emailDataSource[DataSourceType.hiveCache]!.storeOpenedEmail(session, accountId, detailedEmail);
  }

  @override
  Future<DetailedEmail?> getOpenedEmail(Session session, AccountId accountId, EmailId emailId) async {
    final getIncomingEmailedStored = await emailDataSource[DataSourceType.hiveCache]!.getIncomingEmailedStored(session, accountId, emailId);
    final openedEmail = await emailDataSource[DataSourceType.hiveCache]!.getOpenedEmail(session, accountId, emailId);
    if (getIncomingEmailedStored != null) {
      return getIncomingEmailedStored;
    } else {
      return openedEmail;
    }
  }

  @override
  Future<Email?> getEmailStored(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.hiveCache]!.getEmailStored(session, accountId, emailId);
  }

  @override
  Future<void> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail) {
    return emailDataSource[DataSourceType.hiveCache]!.storeSendingEmail(accountId, userName, sendingEmail);
  }

  @override
  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId) {
    return emailDataSource[DataSourceType.hiveCache]!.deleteSendingEmail(accountId, userName, sendingId);
  }
}