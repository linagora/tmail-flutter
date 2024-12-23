import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';

class UnsubscribeEmailInteractor {
  final EmailRepository emailRepository;

  UnsubscribeEmailInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, EmailId emailId) async* {
    try {
      yield Right(UnsubscribeEmailLoading());
      await emailRepository.unsubscribeMail(session, accountId, emailId);
      yield Right(UnsubscribeEmailSuccess());
    } catch (e) {
      yield Left(UnsubscribeEmailFailure(exception: e));
    }
  }
}