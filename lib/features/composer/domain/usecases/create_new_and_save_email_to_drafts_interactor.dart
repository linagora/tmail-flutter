import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class CreateNewAndSaveEmailToDraftsInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;
  final ComposerRepository _composerRepository;

  CreateNewAndSaveEmailToDraftsInteractor(
    this._emailRepository,
    this._mailboxRepository,
    this._composerRepository,
  );

  Stream<dartz.Either<Failure, Success>> execute(CreateEmailRequest createEmailRequest) async* {
    try {
      yield dartz.Right<Failure, Success>(GenerateEmailLoading());

      final listCurrentState = await _getStoredCurrentState(
        session: createEmailRequest.session,
        accountId: createEmailRequest.accountId
      );

      final emailCreated = await _createEmailObject(createEmailRequest);

      if (emailCreated != null) {
        if (createEmailRequest.draftsEmailId == null) {
          yield dartz.Right<Failure, Success>(SaveEmailAsDraftsLoading());

          final emailDraftSaved = await _emailRepository.saveEmailAsDrafts(
            createEmailRequest.session,
            createEmailRequest.accountId,
            emailCreated
          );

          yield dartz.Right<Failure, Success>(
            SaveEmailAsDraftsSuccess(
              emailDraftSaved.id!,
              currentMailboxState: listCurrentState?.value1,
              currentEmailState: listCurrentState?.value2
            )
          );
        } else {
          yield dartz.Right<Failure, Success>(UpdatingEmailDrafts());

          final emailDraftSaved = await _emailRepository.updateEmailDrafts(
            createEmailRequest.session,
            createEmailRequest.accountId,
            emailCreated,
            createEmailRequest.draftsEmailId!
          );

          await _deleteOldDraftsEmail(
            session: createEmailRequest.session,
            accountId: createEmailRequest.accountId,
            draftEmailId: createEmailRequest.draftsEmailId!
          );

          yield dartz.Right<Failure, Success>(
            UpdateEmailDraftsSuccess(
              emailDraftSaved.id!,
              currentMailboxState: listCurrentState?.value1,
              currentEmailState: listCurrentState?.value2
            )
          );
        }
      } else {
        yield dartz.Left<Failure, Success>(GenerateEmailFailure(CannotCreateEmailObjectException()));
      }
    } catch (e) {
      logError('CreateNewAndSaveEmailToDraftsInteractor::execute: Exception: $e');
      if (createEmailRequest.draftsEmailId == null) {
        yield dartz.Left<Failure, Success>(SaveEmailAsDraftsFailure(e));
      } else {
        yield dartz.Left<Failure, Success>(UpdateEmailDraftsFailure(e));
      }
    }
  }

  Future<Email?> _createEmailObject(CreateEmailRequest createEmailRequest) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(createEmailRequest);
      return emailCreated;
    } catch (e) {
      logError('CreateNewAndSaveEmailToDraftsInteractor::_createEmailObject: Exception: $e');
      return null;
    }
  }

  Future<dartz.Tuple2<State?, State?>?> _getStoredCurrentState({
    required Session session,
    required AccountId accountId
  }) async {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ]);

      final mailboxState = listState.first;
      final emailState = listState.last;

      return dartz.Tuple2(mailboxState, emailState);
    } catch (e) {
      logError('CreateNewAndSaveEmailToDraftsInteractor::_getStoredCurrentState: Exception: $e');
      return null;
    }
  }

  Future<void> _deleteOldDraftsEmail({
    required Session session,
    required AccountId accountId,
    required EmailId draftEmailId
  }) async {
    try {
      await _emailRepository.removeEmailDrafts(
        session,
        accountId,
        draftEmailId
      );
    } catch (e) {
      logError('CreateNewAndSaveEmailToDraftsInteractor::_deleteOldDraftsEmail: Exception: $e');
    }
  }
}