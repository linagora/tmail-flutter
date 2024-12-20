import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';

class MarkAsStarMultipleEmailInteractor {
  final EmailRepository _emailRepository;

  MarkAsStarMultipleEmailInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MarkStarAction markStarAction
  ) async* {
    try {
      yield Right(LoadingMarkAsStarMultipleEmailAll());

      final currentEmailState = await _emailRepository.getEmailState(session, accountId);

      final result = await _emailRepository.markAsStar(session, accountId, emailIds, markStarAction);

      if (emailIds.length == result.length) {
        yield Right(MarkAsStarMultipleEmailAllSuccess(
            emailIds.length,
            markStarAction,
            currentEmailState: currentEmailState));
      } else if (result.isEmpty) {
        yield Left(MarkAsStarMultipleEmailAllFailure(markStarAction));
      } else {
        yield Right(MarkAsStarMultipleEmailHasSomeEmailFailure(
            result.length,
            markStarAction,
            currentEmailState: currentEmailState));
      }
    } catch (e) {
      yield Left(MarkAsStarMultipleEmailFailure(markStarAction, e));
    }
  }
}