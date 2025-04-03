import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/clean_and_get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';

class CleanAndGetEmailsInMailboxInteractor {
  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final ThreadRepository _threadRepository;

  const CleanAndGetEmailsInMailboxInteractor(
    this._threadRepository,
    this._getEmailsInMailboxInteractor,
  );

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      EmailFilter? emailFilter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
      bool getLatestChanges = true,
    }
  ) async* {
    try {
      yield Right<Failure, Success>(CleanAndGetAllEmailLoading());

      await _threadRepository.clearEmailCacheAndStateCache(accountId, session);

      yield* _getEmailsInMailboxInteractor.execute(
        session,
        accountId,
        limit: limit,
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: propertiesCreated,
        propertiesUpdated: propertiesUpdated,
        getLatestChanges: getLatestChanges,
      );
    } catch (e) {
      yield Left(CleanAndGetAllEmailFailure(e));
    }
  }
}