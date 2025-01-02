import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

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
    try {
      yield dartz.Right<Failure, Success>(GenerateEmailLoading());

      final emailCreated = await _createEmailObject(createEmailRequest);

      if (emailCreated != null) {
        if (createEmailRequest.draftsEmailId == null) {
          yield dartz.Right<Failure, Success>(SaveEmailAsDraftsLoading());

          final emailDraftSaved = await _emailRepository.saveEmailAsDrafts(
            createEmailRequest.session,
            createEmailRequest.accountId,
            emailCreated,
            cancelToken: cancelToken
          );

          yield dartz.Right<Failure, Success>(
            SaveEmailAsDraftsSuccess(
              emailDraftSaved.id!,
              createEmailRequest.draftsMailboxId,
            )
          );
        } else {
          yield dartz.Right<Failure, Success>(UpdatingEmailDrafts());

          final emailDraftSaved = await _emailRepository.updateEmailDrafts(
            createEmailRequest.session,
            createEmailRequest.accountId,
            emailCreated,
            createEmailRequest.draftsEmailId!,
            cancelToken: cancelToken
          );

          yield dartz.Right<Failure, Success>(
            UpdateEmailDraftsSuccess(emailDraftSaved.id!)
          );
        }
      } else {
        yield dartz.Left<Failure, Success>(GenerateEmailFailure(CannotCreateEmailObjectException()));
      }
    } catch (e) {
      logError('CreateNewAndSaveEmailToDraftsInteractor::execute: Exception: $e');
      if (e is UnknownError && e.message is List<SavingEmailToDraftsCanceledException>) {
        if (createEmailRequest.draftsEmailId == null) {
          yield dartz.Left<Failure, Success>(SaveEmailAsDraftsFailure(SavingEmailToDraftsCanceledException()));
        } else {
          yield dartz.Left<Failure, Success>(UpdateEmailDraftsFailure(SavingEmailToDraftsCanceledException()));
        }
      } else {
        if (createEmailRequest.draftsEmailId == null) {
          yield dartz.Left<Failure, Success>(SaveEmailAsDraftsFailure(e));
        } else {
          yield dartz.Left<Failure, Success>(UpdateEmailDraftsFailure(e));
        }
      }
    }
  }

  Future<Email?> _createEmailObject(CreateEmailRequest createEmailRequest) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true);
      return emailCreated;
    } catch (e) {
      logError('CreateNewAndSaveEmailToDraftsInteractor::_createEmailObject: Exception: $e');
      return null;
    }
  }
}