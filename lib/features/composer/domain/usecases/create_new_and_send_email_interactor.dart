import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/timeout_interceptors.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class CreateNewAndSendEmailInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;
  final ComposerRepository _composerRepository;
  final TimeoutInterceptors _timeoutInterceptors;

  CreateNewAndSendEmailInteractor(
    this._emailRepository,
    this._mailboxRepository,
    this._composerRepository,
    this._timeoutInterceptors,
  );

  Stream<dartz.Either<Failure, Success>> execute({
    required CreateEmailRequest createEmailRequest,
    CancelToken? cancelToken,
    bool enableTimeout = false,
  }) async* {
    SendingEmailArguments? sendingEmailArguments;
    try {
      yield dartz.Right<Failure, Success>(GenerateEmailLoading());

      final listCurrentState = await _getStoredCurrentState(
        session: createEmailRequest.session,
        accountId: createEmailRequest.accountId
      );

      sendingEmailArguments = await _createEmailObject(createEmailRequest);

      if (sendingEmailArguments == null) {
        yield dartz.Left<Failure, Success>(GenerateEmailFailure(CannotCreateEmailObjectException()));
        return;
      }

      if (enableTimeout) {
        _timeoutInterceptors.setTimeout(
          connectionTimeout: AppConfig.sendingMessageTimeout,
          sendTimeout: AppConfig.sendingMessageTimeout,
          receiveTimeout: AppConfig.sendingMessageTimeout,
        );
      }

      yield dartz.Right<Failure, Success>(SendEmailLoading());

      await _emailRepository.sendEmail(
        sendingEmailArguments.session,
        sendingEmailArguments.accountId,
        sendingEmailArguments.emailRequest,
        mailboxRequest: sendingEmailArguments.mailboxRequest,
        cancelToken: cancelToken,
      );

      if (enableTimeout) {
        _timeoutInterceptors.resetTimeout();
      }

      if (sendingEmailArguments.emailRequest.emailIdDestroyed != null) {
        await _deleteOldDraftsEmail(
          session: sendingEmailArguments.session,
          accountId: sendingEmailArguments.accountId,
          draftEmailId: sendingEmailArguments.emailRequest.emailIdDestroyed!,
          cancelToken: cancelToken
        );
      }

      yield dartz.Right<Failure, Success>(
        SendEmailSuccess(
          currentMailboxState: listCurrentState?.value1,
          currentEmailState: listCurrentState?.value2,
          emailRequest: sendingEmailArguments.emailRequest
        )
      );
    } catch (e) {
      logError('CreateNewAndSendEmailInteractor::execute: Exception: $e');
      if (enableTimeout) {
        _timeoutInterceptors.resetTimeout();
      }
      if (e is UnknownError && e.message is List<SendingEmailCanceledException>) {
        yield dartz.Left<Failure, Success>(SendEmailFailure(
          exception: SendingEmailCanceledException(),
          session: sendingEmailArguments?.session,
          accountId: sendingEmailArguments?.accountId,
          emailRequest: sendingEmailArguments?.emailRequest,
          mailboxRequest: sendingEmailArguments?.mailboxRequest,
        ));
      } else if (e is ConnectionTimeout || e is SendTimeout || e is ReceiveTimeout) {
        yield dartz.Left<Failure, Success>(SendEmailFailure(
          exception: SendingEmailTimeoutException(),
          session: sendingEmailArguments?.session,
          accountId: sendingEmailArguments?.accountId,
          emailRequest: sendingEmailArguments?.emailRequest,
          mailboxRequest: sendingEmailArguments?.mailboxRequest,
        ));
      } else {
        yield dartz.Left<Failure, Success>(SendEmailFailure(
          exception: e,
          session: sendingEmailArguments?.session,
          accountId: sendingEmailArguments?.accountId,
          emailRequest: sendingEmailArguments?.emailRequest,
          mailboxRequest: sendingEmailArguments?.mailboxRequest,
        ));
      }
    }
  }

  Future<SendingEmailArguments?> _createEmailObject(CreateEmailRequest createEmailRequest) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(createEmailRequest);
      final sendingEmailArgument = createEmailRequest.toSendingEmailArguments(emailObject: emailCreated);
      return sendingEmailArgument;
    } catch (e) {
      logError('CreateNewAndSendEmailInteractor::_createEmailObject: Exception: $e');
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
      logError('CreateNewAndSendEmailInteractor::_getStoredCurrentState: Exception: $e');
      return null;
    }
  }

  Future<void> _deleteOldDraftsEmail({
    required Session session,
    required AccountId accountId,
    required EmailId draftEmailId,
    CancelToken? cancelToken
  }) async {
    try {
      await _emailRepository.deleteEmailPermanently(
        session,
        accountId,
        draftEmailId,
        cancelToken: cancelToken
      );
    } catch (e) {
      logError('CreateNewAndSendEmailInteractor::_deleteOldDraftsEmail: Exception: $e');
    }
  }
}