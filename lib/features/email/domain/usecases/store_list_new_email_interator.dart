import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_new_email_state.dart';

class StoreListNewEmailInteractor {
  final EmailRepository _emailRepository;

  StoreListNewEmailInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    Map<Email, DetailedEmail> mapDetailedEmails
  ) async* {
    try {
      yield Right<Failure, Success>(StoreNewEmailLoading());

      for (var email in mapDetailedEmails.keys) {
        await _storeNewEmail(session, accountId, email, mapDetailedEmails[email]!);
      }

      yield Right<Failure, Success>(StoreNewEmailSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreNewEmailFailure(e));
    }
  }

  Future<bool> _isNewEmailAlreadyStored(
    Session session,
    AccountId accountId,
    DetailedEmail detailedEmail
  ) async {
    try {
      await _emailRepository.getStoredNewEmail(session, accountId, detailedEmail.emailId);
      return true;
    } catch (err) {
      logError('StoreNewEmailInteractor::_isNewEmailAlreadyStored():EXCEPTION: $err');
      return false;
    }
  }

  Future<void> _storeNewEmail(
    Session session,
    AccountId accountId,
    Email email,
    DetailedEmail detailedEmail
  ) async {
    final isNewEmailExist = await _isNewEmailAlreadyStored(session, accountId, detailedEmail);
    log('StoreNewEmailInteractor::execute():isNewEmailExist: $isNewEmailExist');
    if (!isNewEmailExist) {
      await Future.wait([
        _emailRepository.storeEmail(session, accountId, email),
        _emailRepository.storeDetailedNewEmail(session, accountId, detailedEmail),
      ], eagerError: true);
    }
  }
}