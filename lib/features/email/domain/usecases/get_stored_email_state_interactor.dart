import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_stored_state_email_state.dart';

class GetStoredEmailStateInteractor {
  final EmailRepository _emailRepository;

  GetStoredEmailStateInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      final state = await _emailRepository.getEmailState();
      if (state != null) {
        yield Right<Failure, Success>(GetStoredEmailStateSuccess(state));
      } else {
        yield Left<Failure, Success>(NotFoundEmailState());
      }
    } catch (e) {
      yield Left<Failure, Success>(GetStoredEmailStateFailure(e));
    }
  }
}