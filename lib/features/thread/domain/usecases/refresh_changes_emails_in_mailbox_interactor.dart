import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';

class RefreshChangesEmailsInMailboxInteractor {
  final ThreadRepository threadRepository;

  RefreshChangesEmailsInMailboxInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    jmap.State currentState,
    {
      Set<Comparator>? sort,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
      EmailFilter? emailFilter,
    }
  ) async* {
    yield Right<Failure, Success>(RefreshingState());

    try {
      yield* threadRepository
        .refreshChanges(
          accountId,
          currentState,
          sort: sort,
          propertiesCreated: propertiesCreated,
          propertiesUpdated: propertiesUpdated,
          emailFilter: emailFilter)
        .map(_toGetEmailState);
    } catch (e) {
      yield Left(RefreshChangesAllEmailFailure(e));
    }
  }

  Either<Failure, Success> _toGetEmailState(EmailsResponse emailResponse) {
    final presentationEmailList = emailResponse.emailList
      ?.map((email) => email.toPresentationEmail()).toList() ?? List.empty();

    return Right<Failure, Success>(RefreshChangesAllEmailSuccess(
      emailList: presentationEmailList,
      currentEmailState: emailResponse.state));
  }
}