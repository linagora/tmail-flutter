
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_opened_email_from_cache_state.dart';

class GetOpenedEmailFromCacheInteractor {
  final EmailRepository _emailRepository;

  GetOpenedEmailFromCacheInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, EmailId emailId) async* {
    try {
      yield Right<Failure, Success>(GetOpenedEmailLoading());
      final detailedEmail = await _emailRepository.getOpenedEmail(session, accountId, emailId);
      yield Right<Failure, Success>(GetOpenedEmailSuccess(detailedEmail));
    } catch (e) {
      yield Left<Failure, Success>(GetOpenedEmailFailure(e));
    }
  }
}