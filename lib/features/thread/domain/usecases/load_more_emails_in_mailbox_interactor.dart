import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';

class LoadMoreEmailsInMailboxInteractor {
  final ThreadRepository threadRepository;

  LoadMoreEmailsInMailboxInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
      EmailId? lastEmailId,
    }
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingMoreState());

      yield* threadRepository
        .loadMoreEmails(
          accountId,
          limit: limit,
          sort: sort,
          filter: filter,
          properties: properties,
          lastEmailId: lastEmailId)
        .map(_toGetEmailState);
    } catch (e) {
      yield Left(LoadMoreEmailsFailure(e));
    }
  }

  Either<Failure, Success> _toGetEmailState(EmailsResponse emailResponse) {
    final presentationEmailList = emailResponse.emailList
      ?.map((email) => email.toPresentationEmail()).toList() ?? List.empty();

    return Right<Failure, Success>(LoadMoreEmailsSuccess(presentationEmailList));
  }
}