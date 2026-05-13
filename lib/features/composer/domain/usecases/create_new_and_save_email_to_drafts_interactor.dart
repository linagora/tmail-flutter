import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/unknown_remote_exception.dart';

class CreateNewAndSaveEmailToDraftsInteractor {
  final EmailRepository _emailRepository;
  final ComposerRepository _composerRepository;

  CreateNewAndSaveEmailToDraftsInteractor(
    this._emailRepository,
    this._composerRepository,
  );

  Stream<dartz.Either<Failure, Success>> execute({
    required CreateEmailRequest createEmailRequest,
    CancelToken? cancelToken,
  }) async* {
    final draftEmailId = createEmailRequest.draftsEmailId;
    final isSaveDraft = draftEmailId == null;
    try {
      yield dartz.Right<Failure, Success>(GenerateEmailLoading());

      final emailCreated = await _createEmailObject(createEmailRequest);
      if (emailCreated == null) {
        yield dartz.Left<Failure, Success>(
          GenerateEmailFailure(CannotCreateEmailObjectException()),
        );
        return;
      }

      final draftPayload = (
        session: createEmailRequest.session,
        accountId: createEmailRequest.accountId,
        email: emailCreated,
        draftsMailboxId: createEmailRequest.draftsMailboxId,
      );

      if (isSaveDraft) {
        yield* _saveEmailAsDrafts(
          draftPayload: draftPayload,
          cancelToken: cancelToken,
        );
      } else {
        yield* _updateDraftsEmail(
          draftPayload: draftPayload,
          draftsEmailId: draftEmailId,
          cancelToken: cancelToken,
        );
      }
    } catch (e, st) {
      logError(
        'CreateNewAndSaveEmailToDraftsInteractor::execute: exception=${e.runtimeType}',
        stackTrace: st,
      );
      yield* _handleFailure(exception: e, isSaveDraft: isSaveDraft);
    }
  }

  Stream<dartz.Either<Failure, Success>> _saveEmailAsDrafts({
    required ({
      AccountId accountId,
      MailboxId? draftsMailboxId,
      Email email,
      Session session,
    }) draftPayload,
    CancelToken? cancelToken,
  }) async* {
    try {
      yield dartz.Right<Failure, Success>(SaveEmailAsDraftsLoading());

      final emailDraftSaved = await _emailRepository.saveEmailAsDrafts(
        draftPayload.session,
        draftPayload.accountId,
        draftPayload.email,
        cancelToken: cancelToken,
      );

      final newEmailId = emailDraftSaved.id;

      if (newEmailId == null) {
        yield dartz.Left<Failure, Success>(
          SaveEmailAsDraftsFailure(NotFoundEmailIdException()),
        );
      } else {
        yield dartz.Right<Failure, Success>(
          SaveEmailAsDraftsSuccess(
            newEmailId,
            draftPayload.draftsMailboxId,
          ),
        );
      }
    } catch (e, st) {
      logError(
        'CreateNewAndSaveEmailToDraftsInteractor::_saveEmailAsDrafts: exception=${e.runtimeType}',
        stackTrace: st,
      );
      yield* _handleFailure(exception: e, isSaveDraft: true);
    }
  }

  Stream<dartz.Either<Failure, Success>> _updateDraftsEmail({
    required ({
      AccountId accountId,
      MailboxId? draftsMailboxId,
      Session session,
      Email email,
    }) draftPayload,
    required EmailId draftsEmailId,
    CancelToken? cancelToken,
  }) async* {
    try {
      yield dartz.Right<Failure, Success>(UpdatingEmailDrafts());

      final emailDraftSaved = await _emailRepository.updateEmailDrafts(
        draftPayload.session,
        draftPayload.accountId,
        draftPayload.email,
        draftsEmailId,
        cancelToken: cancelToken,
      );

      final newEmailId = emailDraftSaved.id;

      if (newEmailId == null) {
        yield dartz.Left<Failure, Success>(
          UpdateEmailDraftsFailure(NotFoundEmailIdException()),
        );
      } else {
        yield dartz.Right<Failure, Success>(
          UpdateEmailDraftsSuccess(
            emailId: newEmailId,
            attachments: emailDraftSaved.allAttachments,
            htmlBodyAttachments: emailDraftSaved.htmlBodyAttachments,
          ),
        );
      }
    } catch (e, st) {
      logError(
        'CreateNewAndSaveEmailToDraftsInteractor::_updateDraftsEmail: exception=${e.runtimeType}',
        stackTrace: st,
      );
      yield* _handleFailure(exception: e, isSaveDraft: false);
    }
  }

  Stream<dartz.Either<Failure, Success>> _handleFailure({
    dynamic exception,
    required bool isSaveDraft,
  }) async* {
    if (exception is UnknownRemoteException &&
        exception.error is List<SavingEmailToDraftsCanceledException>) {
      exception = SavingEmailToDraftsCanceledException();
    }

    yield dartz.Left<Failure, Success>(
      isSaveDraft
          ? SaveEmailAsDraftsFailure(exception)
          : UpdateEmailDraftsFailure(exception),
    );
  }

  Future<Email?> _createEmailObject(CreateEmailRequest createEmailRequest) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true,
        isDraft: true,
      );
      return emailCreated;
    } catch (e, st) {
      // Privacy: log type only — exception message may embed email content.
      logError(
        'CreateNewAndSaveEmailToDraftsInteractor::_createEmailObject: exception=${e.runtimeType}',
        stackTrace: st,
      );
      return null;
    }
  }
}