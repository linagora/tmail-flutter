
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/search_email_filter_request.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_starred_state.dart';

class MarkAllSearchAsStarredInteractor {

  final ThreadRepository threadRepository;

  MarkAllSearchAsStarredInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    SearchEmailFilterRequest filterRequest
  ) async* {
    try {
      yield Right(MarkAllSearchAsStarredLoading());

      final listEmailId = await threadRepository.markAllSearchAsStarred(
        session,
        accountId,
        filterRequest);

      yield Right(MarkAllSearchAsStarredSuccess(listEmailId));
    } catch (e) {
      yield Left(MarkAllSearchAsStarredFailure(e));
    }
  }
}