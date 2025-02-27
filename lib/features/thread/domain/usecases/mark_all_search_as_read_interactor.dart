
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_read_state.dart';

class MarkAllSearchAsReadInteractor {

  final ThreadRepository threadRepository;

  MarkAllSearchAsReadInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  ) async* {
    try {
      yield Right(MarkAllSearchAsReadLoading());
      final listEmailId = await threadRepository.markAllSearchAsRead(
        session,
        accountId,
        searchEmailFilter,
        moreFilterCondition: moreFilterCondition,
      );
      yield Right(MarkAllSearchAsReadSuccess(listEmailId));
    } catch (e) {
      yield Left(MarkAllSearchAsReadFailure(e));
    }
  }
}