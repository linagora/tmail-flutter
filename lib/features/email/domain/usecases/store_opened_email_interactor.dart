import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_cache_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_opened_email_state.dart';

class StoreOpenedEmailInteractor {
  final EmailRepository _emailRepository;

  StoreOpenedEmailInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    DetailedEmail detailedEmail
  ) async* {
    try {
      yield Right<Failure, Success>(StoreOpenedEmailLoading());
      final isOpenedEmailExist = await _isOpenedEmailAlreadyStored(session, accountId, detailedEmail);
      log('StoreOpenedEmailInteractor::execute():isOpenedEmailExist: $isOpenedEmailExist');
      if (!isOpenedEmailExist) {
        await _emailRepository.storeOpenedEmail(session, accountId, detailedEmail);
        yield Right<Failure, Success>(StoreOpenedEmailSuccess());
      } else {
        yield Left<Failure, Success>(StoreOpenedEmailFailure(OpenedEmailAlreadyStoredException()));
      }
    } catch (e) {
      yield Left<Failure, Success>(StoreOpenedEmailFailure(e));
    }
  }

  Future<bool> _isOpenedEmailAlreadyStored(Session session, AccountId accountId, DetailedEmail detailedEmail) async {
    try {
      await _emailRepository.getStoredOpenedEmail(session, accountId, detailedEmail.emailId);
      return true;
    } catch (err) {
      logError('StoreOpenedEmailInteractor::isOpenedEmailAlreadyStored():EXCEPTION: $err');
      return false;
    }
  }
}