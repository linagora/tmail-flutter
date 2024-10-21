import 'dart:async';

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
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

class CreateNewAndSendEmailInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;
  final ComposerRepository _composerRepository;

  CreateNewAndSendEmailInteractor(
    this._emailRepository,
    this._mailboxRepository,
    this._composerRepository,
  );

  Stream<dartz.Either<Failure, Success>> execute({
    required CreateEmailRequest createEmailRequest,
    CancelToken? cancelToken,
    Duration? timeout,
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

      yield dartz.Right<Failure, Success>(SendEmailLoading());

      await _emailRepository.sendEmail(
        sendingEmailArguments.session,
        sendingEmailArguments.accountId,
        sendingEmailArguments.emailRequest,
        mailboxRequest: sendingEmailArguments.mailboxRequest,
        cancelToken: cancelToken,
        timeout: timeout,
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
          currentMailboxState: listCurrentState?.value1,
          currentEmailState: listCurrentState?.value2,
          emailRequest: sendingEmailArguments.emailRequest
        )
      );
    } catch (e) {
      logError('CreateNewAndSendEmailInteractor::execute: Exception: $e');
      if (e is UnknownError && e.message is List<SendingEmailCanceledException>) {
        yield dartz.Left<Failure, Success>(SendEmailFailure(
          exception: SendingEmailCanceledException(),
          session: sendingEmailArguments?.session,
          accountId: sendingEmailArguments?.accountId,
          emailRequest: sendingEmailArguments?.emailRequest,
          mailboxRequest: sendingEmailArguments?.mailboxRequest,
        ));
      } else if (e is TimeoutException) {
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
  }) async {
    try {
      await _emailRepository.deleteEmailPermanently(
        session,
        accountId,
        draftEmailId,
      );
    } catch (e) {
      logError('CreateNewAndSendEmailInteractor::_deleteOldDraftsEmail: Exception: $e');
    }
  }
}