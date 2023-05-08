import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';

class MarkAsStarEmailInteractor {
  final EmailRepository emailRepository;

  MarkAsStarEmailInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, Email email, MarkStarAction markStarAction) async* {
    try {
      final currentEmailState = await emailRepository.getEmailState(accountId);
      final result = await emailRepository.markAsStar(session, accountId, [email], markStarAction);
      if (result.isNotEmpty) {
        final updatedEmail = email.updatedEmail(newKeywords: result.first.keywords);
        yield Right(MarkAsStarEmailSuccess(
            updatedEmail,
            markStarAction,
            currentEmailState: currentEmailState));
      } else {
        yield Left(MarkAsStarEmailFailure(null, markStarAction));
      }
    } catch (e) {
      yield Left(MarkAsStarEmailFailure(e, markStarAction));
    }
  }
}