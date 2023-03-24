import 'package:core/core.dart';
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
    List<Email> emails,
    MarkStarAction markStarAction
  ) async* {
    try {
      yield Right(LoadingMarkAsStarMultipleEmailAll());

      final currentEmailState = await _emailRepository.getEmailState();

      final listEmailNeedMarkStar = emails
          .where((email) => markStarAction == MarkStarAction.unMarkStar ? email.hasStarred : !email.hasStarred)
          .toList();

      final result = await _emailRepository.markAsStar(session, accountId, listEmailNeedMarkStar, markStarAction);

      if (listEmailNeedMarkStar.length == result.length) {
        final countMarkStarSuccess = emails.length;
        yield Right(MarkAsStarMultipleEmailAllSuccess(
            countMarkStarSuccess,
            markStarAction,
            currentEmailState: currentEmailState));
      } else if (result.isEmpty) {
        yield Left(MarkAsStarMultipleEmailAllFailure(markStarAction));
      } else {
        final countMarkStarSuccess = emails.length - (listEmailNeedMarkStar.length - result.length);
        yield Right(MarkAsStarMultipleEmailHasSomeEmailFailure(
            countMarkStarSuccess,
            markStarAction,
            currentEmailState: currentEmailState));
      }
    } catch (e) {
      yield Left(MarkAsStarMultipleEmailFailure(e, markStarAction));
    }
  }
}