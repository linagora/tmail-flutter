import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/dismiss_twp_warning_state.dart';

class DismissTwpWarningInteractor {
  final EmailRepository emailRepository;

  DismissTwpWarningInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    int index,
  ) async* {
    try {
      await emailRepository.dismissTwpWarning(
        session,
        accountId,
        emailId,
        index,
      );
      yield Right(DismissTwpWarningSuccess(emailId, index));
    } catch (e) {
      yield Left(DismissTwpWarningFailure(index: index, exception: e));
    }
  }
}
