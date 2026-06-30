import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';

class CreateNewAndSendEmailInteractor {
  final EmailRepository _emailRepository;
  final ComposerRepository _composerRepository;

  CreateNewAndSendEmailInteractor(
    this._emailRepository,
    this._composerRepository,
  );

  Stream<dartz.Either<Failure, Success>> execute({
    required CreateEmailRequest createEmailRequest,
  }) async* {
    SendingEmailArguments? sendingEmailArguments;
    try {
      yield dartz.Right<Failure, Success>(GenerateEmailLoading());

      sendingEmailArguments = await _createEmailObject(createEmailRequest);

      if (sendingEmailArguments != null) {
        yield dartz.Right<Failure, Success>(SendEmailLoading());

        await _emailRepository.sendEmail(
          sendingEmailArguments.session,
          sendingEmailArguments.accountId,
          sendingEmailArguments.emailRequest,
          mailboxRequest: sendingEmailArguments.mailboxRequest,
        );

        if (sendingEmailArguments.emailRequest.emailIdDestroyed != null) {
          await _deleteOldDraftsEmail(
            session: sendingEmailArguments.session,
            accountId: sendingEmailArguments.accountId,
            draftEmailId: sendingEmailArguments.emailRequest.emailIdDestroyed!,
          );
        }

        yield dartz.Right<Failure, Success>(
          SendEmailSuccess(
            emailRequest: sendingEmailArguments.emailRequest
          )
        );
      } else {
        yield dartz.Left<Failure, Success>(GenerateEmailFailure(CannotCreateEmailObjectException()));
      }
    } catch (e) {
      logWarning('CreateNewAndSendEmailInteractor::execute: Exception: $e');
      yield dartz.Left<Failure, Success>(SendEmailFailure(
        exception: e,
        session: sendingEmailArguments?.session,
        accountId: sendingEmailArguments?.accountId,
        emailRequest: sendingEmailArguments?.emailRequest,
        mailboxRequest: sendingEmailArguments?.mailboxRequest,
      ));
    }
  }

  Future<SendingEmailArguments?> _createEmailObject(CreateEmailRequest createEmailRequest) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(createEmailRequest);
      final sendingEmailArgument = createEmailRequest.toSendingEmailArguments(emailObject: emailCreated);
      return sendingEmailArgument;
    } catch (e) {
      logWarning('CreateNewAndSendEmailInteractor::_createEmailObject: Exception: $e');
      return null;
    }
  }

  Future<void> _deleteOldDraftsEmail({
    required Session session,
    required AccountId accountId,
    required EmailId draftEmailId,
  }) async {
    try {
      await _emailRepository.deleteEmailPermanently(
        session,
        accountId,
        draftEmailId,
      );
    } catch (e) {
      logWarning('CreateNewAndSendEmailInteractor::_deleteOldDraftsEmail: Exception: $e');
    }
  }
}