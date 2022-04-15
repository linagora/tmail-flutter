import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';

class MarkAsStarMultipleEmailInteractor {
  final EmailRepository _emailRepository;

  MarkAsStarMultipleEmailInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      List<Email> emails,
      MarkStarAction markStarAction
  ) async* {
    try {
      final listEmailNeedMarkStar = emails
          .where((email) => markStarAction == MarkStarAction.unMarkStar ? email.hasStarred : !email.hasStarred)
          .toList();

      final result = await _emailRepository.markAsStar(accountId, listEmailNeedMarkStar, markStarAction);

      if (listEmailNeedMarkStar.length == result.length) {
        final countMarkStarSuccess = emails.length;
        yield Right(MarkAsStarMultipleEmailAllSuccess(countMarkStarSuccess, markStarAction));
      } else if (result.isEmpty) {
        yield Left(MarkAsStarMultipleEmailAllFailure(markStarAction));
      } else {
        final countMarkStarSuccess = emails.length - (listEmailNeedMarkStar.length - result.length);
        yield Right(MarkAsStarMultipleEmailHasSomeEmailFailure(countMarkStarSuccess, markStarAction));
      }
    } catch (e) {
      yield Left(MarkAsStarMultipleEmailFailure(e, markStarAction));
    }
  }
}