import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_cache_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_new_email_state.dart';

class StoreNewEmailInteractor {
  final EmailRepository _emailRepository;

  StoreNewEmailInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    Email email,
    DetailedEmail detailedEmail
  ) async* {
    try {
      yield Right<Failure, Success>(StoreNewEmailLoading());
      final isNewEmailExist = await _isNewEmailAlreadyStored(session, accountId, detailedEmail);
      log('StoreNewEmailInteractor::execute():isNewEmailExist: $isNewEmailExist');
      if (!isNewEmailExist) {
        await Future.wait([
          _emailRepository.storeEmail(session, accountId, email),
          _emailRepository.storeDetailedNewEmail(session, accountId, detailedEmail),
        ], eagerError: true);
        log('StoreNewEmailInteractor::execute():Store Success | EMAIL: ${detailedEmail.emailId} | TIME: ${detailedEmail.createdTime}');
        yield Right<Failure, Success>(StoreNewEmailSuccess());
      } else {
        log('StoreNewEmailInteractor::execute():Store Failure | EMAIL: ${detailedEmail.emailId} | TIME: ${detailedEmail.createdTime}');
        yield Left<Failure, Success>(StoreNewEmailFailure(NewEmailAlreadyStoredException()));
      }
    } catch (e) {
      yield Left<Failure, Success>(StoreNewEmailFailure(e));
    }
  }

  Future<bool> _isNewEmailAlreadyStored(Session session, AccountId accountId, DetailedEmail detailedEmail) async {
    try {
      await _emailRepository.getStoredNewEmail(session, accountId, detailedEmail.emailId);
      return true;
    } catch (err) {
      logError('StoreNewEmailInteractor::_isNewEmailAlreadyStored():EXCEPTION: $err');
      return false;
    }
  }
}