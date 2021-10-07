import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:model/model.dart';

class GetEmailsInMailboxInteractor {
  final ThreadRepository threadRepository;

  GetEmailsInMailboxInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    {
      int? position,
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
      MailboxId? inMailboxId
    }
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingState());

      yield* threadRepository
        .getAllEmail(
          accountId,
          position: position,
          limit: limit,
          sort: sort,
          filter: filter,
          propertiesCreated: propertiesCreated,
          propertiesUpdated: propertiesUpdated,
          inMailboxId: inMailboxId)
        .map(_toGetEmailState);
    } catch (e) {
      yield Left(GetAllEmailFailure(e));
    }
  }

  Either<Failure, Success> _toGetEmailState(EmailResponse emailResponse) {
    final presentationEmailList = emailResponse.emailList
      ?.map((email) => email.toPresentationEmail()).toList() ?? List.empty();

    return Right<Failure, Success>(GetAllEmailSuccess(
      emailList: presentationEmailList,
      currentEmailState: emailResponse.state));
  }
}