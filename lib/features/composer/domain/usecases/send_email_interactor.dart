import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

class SendEmailInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  SendEmailInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {
      SendingEmailActionType? sendingEmailActionType
    }
  ) async* {
    try {
      yield Right<Failure, Success>(SendEmailLoading());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;
      log('SendEmailInteractor::execute:currentMailboxState: $currentMailboxState | currentEmailState: $currentEmailState');

      final outboxFolder = await _getOutboxMailbox(session, accountId) ?? await _createOutboxFolder(session, accountId);
      log('SendEmailInteractor::execute:outboxFolder: $outboxFolder');
      if (outboxFolder == null || outboxFolder.id == null) {
        yield Left<Failure, Success>(SendEmailFailure(
          session: session,
          accountId: accountId,
          emailRequest: emailRequest,
          sendingEmailActionType: sendingEmailActionType,
          exception: NotFoundOutboxFolderException()
        ));
        return;
      }

      await _emailRepository.sendEmail(
        session,
        accountId,
        emailRequest,
        outboxFolder.id!
      );

      if (emailRequest.emailIdDestroyed != null) {
        await _deleteEmailDrafts(
          session,
          accountId,
          emailRequest.emailIdDestroyed!
        );
      }

      yield Right<Failure, Success>(SendEmailSuccess(
        currentEmailState: currentEmailState,
        currentMailboxState: currentMailboxState,
        emailRequest: emailRequest
      ));
    } catch (e) {
      yield Left<Failure, Success>(SendEmailFailure(
        exception: e,
        session: session,
        accountId: accountId,
        emailRequest: emailRequest,
        sendingEmailActionType: sendingEmailActionType,
      ));
    }
  }

  Future<Mailbox?> _getOutboxMailbox(Session session, AccountId accountId) async {
    return await _getOutboxMailboxRole(session, accountId) ??
      await _getOutboxMailboxByName(session, accountId);
  }

  Future<Mailbox?> _getOutboxMailboxRole(Session session, AccountId accountId) async {
    try {
      final outboxFolder = await _mailboxRepository.getMailboxByRole(
        session,
        accountId,
        Role(PresentationMailbox.outboxRole.inCaps)
      );
      return outboxFolder;
    } catch (e) {
      logError('SendEmailInteractor::_getOutboxMailboxRole:Exception: $e');
      return null;
    }
  }

  Future<Mailbox?> _getOutboxMailboxByName(Session session, AccountId accountId) async {
    try {
      final outboxFolder = await _mailboxRepository.getMailboxByName(
        session,
        accountId,
        MailboxName(PresentationMailbox.outboxRole.inCaps)
      );
      return outboxFolder;
    } catch (e) {
      logError('SendEmailInteractor::_getOutboxMailboxByName:Exception: $e');
      return null;
    }
  }

  Future<Mailbox?> _createOutboxFolder(Session session, AccountId accountId) async {
    try {
      final outboxFolder = await _mailboxRepository.createNewMailbox(
        session,
        accountId,
        CreateNewMailboxRequest(newName: MailboxName(PresentationMailbox.outboxRole.inCaps))
      );
      return outboxFolder;
    } catch (e) {
      logError('SendEmailInteractor::_createOutboxFolder:Exception: $e');
      return null;
    }
  }

  Future<void> _deleteEmailDrafts(Session session, AccountId accountId, EmailId emailDraftId) async {
    try {
      await _emailRepository.deleteEmailPermanently(session, accountId, emailDraftId);
    } catch (e) {
      logError('SendEmailInteractor::_deleteEmailDrafts:Exception: $e');
    }
  }
}