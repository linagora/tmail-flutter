import 'dart:async';

import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/print_file_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/view_entire_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';

class EmailRepositoryImpl extends EmailRepository {

  final Map<DataSourceType, EmailDataSource> emailDataSource;
  final HtmlDataSource _htmlDataSource;
  final StateDataSource _stateDataSource;
  final PrintFileDataSource _printFileDataSource;

  EmailRepositoryImpl(
    this.emailDataSource,
    this._htmlDataSource,
    this._stateDataSource,
    this._printFileDataSource,
  );

  @override
  Future<Email> getEmailContent(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {Properties? additionalProperties}
  ) {
    return emailDataSource[DataSourceType.network]!.getEmailContent(
      session,
      accountId,
      emailId,
      additionalProperties: additionalProperties);
  }

  @override
  Future<void> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {
      CreateNewMailboxRequest? mailboxRequest,
      CancelToken? cancelToken
    }
  ) async {
    await emailDataSource[DataSourceType.network]!.sendEmail(
      session,
      accountId,
      emailRequest,
      mailboxRequest: mailboxRequest,
      cancelToken: cancelToken,
    );

    if (emailRequest.isEmailAnswered) {
      try {
        await emailDataSource[DataSourceType.hiveCache]!.markAsAnswered(
          session,
          accountId,
          [emailRequest.emailIdAnsweredOrForwarded!],
        );
      } catch (e) {
        logError('EmailRepositoryImpl::sendEmail::markAsAnswered:Exception $e');
      }
    } else if (emailRequest.isEmailForwarded) {
      try {
        await emailDataSource[DataSourceType.hiveCache]!.markAsForwarded(
          session,
          accountId,
          [emailRequest.emailIdAnsweredOrForwarded!],
        );
      } catch (e) {
        logError('EmailRepositoryImpl::sendEmail::markAsForwarded:Exception $e');
      }
    }

    return Future.value();
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsRead(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    ReadActions readActions,
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.markAsRead(
      session,
      accountId,
      emailIds,
      readActions,
    );

    try {
      await emailDataSource[DataSourceType.hiveCache]!.markAsRead(
        session,
        accountId,
        result.emailIdsSuccess,
        readActions,
      );
    } catch (e) {
      logError('EmailRepositoryImpl::markAsRead:exception $e');
    }

    return result;
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
  ) async {
    final result = await emailDataSource[DataSourceType.network]
      !.moveToMailbox(
      session,
      accountId,
      moveRequest,
    );
    final updatedCurrentMailboxes = moveRequest.currentMailboxes.map(
      (key, value) => MapEntry(
        key,
        value.where(result.emailIdsSuccess.contains).toList(),
      ),
    );
    
    try {
      await emailDataSource[DataSourceType.hiveCache]
        !.moveToMailbox(
          session,
          accountId,
          MoveToMailboxRequest(
            updatedCurrentMailboxes,
            moveRequest.destinationMailboxId,
            moveRequest.moveAction,
            moveRequest.emailActionType,
            destinationPath: moveRequest.destinationPath,
          ),
        );
    } catch (e) {
      logError('EmailRepositoryImpl::moveToMailbox:exception $e');
    }

    return result;
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsStar(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MarkStarAction markStarAction
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.markAsStar(
      session,
      accountId,
      emailIds,
      markStarAction,
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]!.markAsStar(
        session,
        accountId,
        result.emailIdsSuccess,
        markStarAction
      );
    } catch (e) {
      logError('EmailRepositoryImpl::markAsStar:exception $e');
    }
    return result;
  }

  @override
  Future<List<EmailContent>> transformEmailContent(
    List<EmailContent> emailContents,
    Map<String, String> mapCidImageDownloadUrl,
    TransformConfiguration transformConfiguration
  ) async {
    return await Future.wait(emailContents
      .map((emailContent) async {
        return await _htmlDataSource.transformEmailContent(
          emailContent,
          mapCidImageDownloadUrl,
          transformConfiguration,
        );
      })
      .toList());
  }

  @override
  Future<Email> saveEmailAsDrafts(
    Session session,
    AccountId accountId,
    Email email,
    {CancelToken? cancelToken}
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.saveEmailAsDrafts(
      session,
      accountId,
      email,
      cancelToken: cancelToken
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]!.saveEmailAsDrafts(
        session,
        accountId,
        result,
        cancelToken: cancelToken
      );
    } catch (e) {
      logError('EmailRepositoryImpl::saveEmailAsDrafts:exception $e');
    }
    return result;
  }

  @override
  Future<bool> removeEmailDrafts(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.removeEmailDrafts(
      session,
      accountId,
      emailId,
      cancelToken: cancelToken
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]!.removeEmailDrafts(
        session,
        accountId,
        emailId,
        cancelToken: cancelToken
      );
    } catch (e) {
      logError('EmailRepositoryImpl::removeEmailDrafts:exception $e');
    }
    return result;
  }

  @override
  Future<Email> updateEmailDrafts(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.updateEmailDrafts(
      session,
      accountId,
      newEmail,
      oldEmailId,
      cancelToken: cancelToken
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]!.updateEmailDrafts(
        session,
        accountId,
        result,
        oldEmailId,
      );
    } catch (e) {
      logError('EmailRepositoryImpl::updateEmailDrafts:exception $e');
    }
    return result;
  }

  @override
  Future<Email> saveEmailAsTemplate(
    Session session,
    AccountId accountId,
    Email email,
    {
      CreateNewMailboxRequest? createNewMailboxRequest,
      CancelToken? cancelToken,
    }
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.saveEmailAsTemplate(
      session,
      accountId,
      email,
      createNewMailboxRequest: createNewMailboxRequest,
      cancelToken: cancelToken
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]!.saveEmailAsTemplate(
        session,
        accountId,
        result,
        createNewMailboxRequest: createNewMailboxRequest,
        cancelToken: cancelToken
      );
    } catch (e) {
      logError('EmailRepositoryImpl::saveEmailAsTemplate:exception $e');
    }
    return result;
  }

  @override
  Future<Email> updateEmailTemplate(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.updateEmailTemplate(
      session,
      accountId,
      newEmail,
      oldEmailId,
      cancelToken: cancelToken
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]!.updateEmailTemplate(
        session,
        accountId,
        result,
        oldEmailId,
      );
    } catch (e) {
      logError('EmailRepositoryImpl::updateEmailTemplate:exception $e');
    }
    return result;
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> deleteMultipleEmailsPermanently(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
  ) async {
    final result = await emailDataSource[DataSourceType.network]
      !.deleteMultipleEmailsPermanently(
      session,
      accountId,
      emailIds,
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]
        !.deleteMultipleEmailsPermanently(session, accountId, result.emailIdsSuccess);
    } catch (e) {
      logError('EmailRepositoryImpl::deleteMultipleEmailsPermanently:exception $e');
    }

    return result;
  }

  @override
  Future<bool> deleteEmailPermanently(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) async {
    final result = await emailDataSource[DataSourceType.network]!.deleteEmailPermanently(
      session,
      accountId,
      emailId,
      cancelToken: cancelToken
    );
    try {
      await emailDataSource[DataSourceType.hiveCache]!.deleteEmailPermanently(
        session,
        accountId,
        emailId,
      );
    } catch (e) {
      logError('EmailRepositoryImpl::deleteEmailPermanently:exception $e');
    }

    return result;
  }

  @override
  Future<jmap.State?> getEmailState(Session session, AccountId accountId) {
    return _stateDataSource.getState(accountId, session.username, StateType.email);
  }

  @override
  Future<void> storeDetailedNewEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return emailDataSource[DataSourceType.hiveCache]!.storeDetailedNewEmail(session, accountId, detailedEmail);
  }

  @override
  Future<Email> getDetailedEmailById(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.network]!.getDetailedEmailById(session, accountId, emailId);
  }

  @override
  Future<void> storeEmail(Session session, AccountId accountId, Email email) {
    return emailDataSource[DataSourceType.hiveCache]!.storeEmail(session, accountId, email);
  }

  @override
  Future<void> storeOpenedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return emailDataSource[DataSourceType.hiveCache]!.storeOpenedEmail(session, accountId, detailedEmail);
  }

  @override
  Future<DetailedEmail> getStoredOpenedEmail(Session session, AccountId accountId, EmailId emailId) async {
    return emailDataSource[DataSourceType.hiveCache]!.getStoredOpenedEmail(session, accountId, emailId);
  }

  @override
  Future<Email> getStoredEmail(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.hiveCache]!.getStoredEmail(session, accountId, emailId);
  }

  @override
  Future<DetailedEmail> getStoredNewEmail(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.hiveCache]!.getStoredNewEmail(session, accountId, emailId);
  }

  @override
  Future<String> transformHtmlEmailContent(String htmlContent, TransformConfiguration configuration) {
    return _htmlDataSource.transformHtmlEmailContent(htmlContent, configuration);
  }

  @override
  Future<void> unsubscribeMail(Session session, AccountId accountId, EmailId emailId) {
    return emailDataSource[DataSourceType.network]!.unsubscribeMail(session, accountId, emailId);
  }

  @override
  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest) {
    return emailDataSource[DataSourceType.network]!.restoreDeletedMessage(restoredDeletedMessageRequest);
  }

  @override
  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId) {
    return emailDataSource[DataSourceType.network]!.getRestoredDeletedMessage(emailRecoveryActionId);
  }

  @override
  Future<void> printEmail(EmailPrint emailPrint) {
    return _printFileDataSource.printEmail(emailPrint);
  }

  @override
  Future<String> generateEntireMessageAsDocument(ViewEntireMessageRequest entireMessageRequest) {
    return emailDataSource[DataSourceType.local]!.generateEntireMessageAsDocument(entireMessageRequest);
  }

  @override
  Future<void> addLabelToEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  ) {
    return emailDataSource[DataSourceType.network]!.addLabelToEmail(
      session,
      accountId,
      emailId,
      labelKeyword,
    );
  }

  @override
  Future<void> addLabelToThread(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
  ) {
    return emailDataSource[DataSourceType.network]!.addLabelToThread(
      session,
      accountId,
      emailIds,
      labelKeyword,
    );
  }

  @override
  Future<void> removeLabelFromEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  ) {
    return emailDataSource[DataSourceType.network]!.removeLabelFromEmail(
      session,
      accountId,
      emailId,
      labelKeyword,
    );
  }

  @override
  Future<void> removeLabelFromThread(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
  ) {
    return emailDataSource[DataSourceType.network]!.removeLabelFromThread(
      session,
      accountId,
      emailIds,
      labelKeyword,
    );
  }
}