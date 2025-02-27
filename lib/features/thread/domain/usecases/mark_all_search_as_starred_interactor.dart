
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_starred_state.dart';

class MarkAllSearchAsStarredInteractor {

  final ThreadRepository threadRepository;

  MarkAllSearchAsStarredInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  ) async* {
    try {
      yield Right(MarkAllSearchAsStarredLoading());
      final listEmailId = await threadRepository.markAllSearchAsStarred(
        session,
        accountId,
        searchEmailFilter,
        moreFilterCondition: moreFilterCondition,
      );
      yield Right(MarkAllSearchAsStarredSuccess(listEmailId));
    } catch (e) {
      yield Left(MarkAllSearchAsStarredFailure(e));
    }
  }
}