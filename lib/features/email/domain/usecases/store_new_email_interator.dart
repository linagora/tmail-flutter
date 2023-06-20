import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
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
      await Future.wait([
        _emailRepository.storeEmail(session, accountId, email),
        _emailRepository.storeDetailedNewEmail(session, accountId, detailedEmail),
      ]);
      yield Right<Failure, Success>(StoreNewEmailSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreNewEmailFailure(e));
    }
  }
}