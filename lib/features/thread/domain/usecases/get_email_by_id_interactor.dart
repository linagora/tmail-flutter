import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';

class GetEmailByIdInteractor {
  final ThreadRepository _threadRepository;
  final EmailRepository _emailRepository;

  GetEmailByIdInteractor(this._threadRepository, this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {
      Properties? properties,
      PresentationMailbox? mailboxContain,
    }
  ) async* {
    try {
      yield Right<Failure, Success>(GetEmailByIdLoading());
      if (PlatformInfo.isMobile) {
        yield* _getStoredEmail(session, accountId, emailId, properties: properties);
      } else {
        yield* _getEmailByIdFromServer(
          session,
          accountId,
          emailId,
          properties: properties,
          mailboxContain: mailboxContain,
        );
      }
    } catch (e) {
      logError('GetEmailByIdInteractor::execute():EXCEPTION: $e');
      yield Left<Failure, Success>(GetEmailByIdFailure(e));
    }
  }

  Stream<Either<Failure, Success>> _getEmailByIdFromServer(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {
      Properties? properties,
      PresentationMailbox? mailboxContain,
    }
  ) async* {
    try {
      final email = await _threadRepository.getEmailById(session, accountId, emailId, properties: properties);
      yield Right<Failure, Success>(
        GetEmailByIdSuccess(email, mailboxContain: mailboxContain)
      );
    } catch (e) {
      logError('GetEmailByIdInteractor::_getEmailByIdFromServer():EXCEPTION: $e');
      yield Left<Failure, Success>(GetEmailByIdFailure(e));
    }

  }

  Stream<Either<Failure, Success>> _getStoredEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {
      Properties? properties,
    }
  ) async* {
    try {
      final email = await _emailRepository.getStoredEmail(session, accountId, emailId);
      yield Right<Failure, Success>(GetEmailByIdSuccess(email.toPresentationEmail()));
    } catch (e) {
      logError('GetEmailByIdInteractor::_tryToGetEmailFromCache():EXCEPTION: $e');
      yield* _getEmailByIdFromServer(session, accountId, emailId, properties: properties);
    }
  }
}