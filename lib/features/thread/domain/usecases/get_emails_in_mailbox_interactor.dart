import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';

class GetEmailsInMailboxInteractor {
  final ThreadRepository threadRepository;

  GetEmailsInMailboxInteractor(this.threadRepository);

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
      bool useCache = true,
      bool forceEmailQuery = false,
    }
  ) async* {
    try {
      yield Right<Failure, Success>(GetAllEmailLoading());

      late Stream<EmailsResponse> sourceStream;

      if (forceEmailQuery) {
        sourceStream = threadRepository.forceQueryAllEmailsForWeb(
          session: session,
          accountId: accountId,
          limit: limit,
          sort: sort,
          emailFilter: emailFilter,
          propertiesCreated: propertiesCreated,
        );
      } else if (useCache) {
        sourceStream = threadRepository.getAllEmail(
          session,
          accountId,
          limit: limit,
          sort: sort,
          emailFilter: emailFilter,
          propertiesCreated: propertiesCreated,
          propertiesUpdated: propertiesUpdated,
          getLatestChanges: getLatestChanges,
        );
      } else {
        sourceStream = threadRepository.loadAllEmailInFolderWithoutCache(
          session: session,
          accountId: accountId,
          limit: limit,
          sort: sort,
          emailFilter: emailFilter,
          propertiesCreated: propertiesCreated,
        );
      }

      yield* sourceStream.map(
        (emailResponse) => _toGetEmailState(
          emailResponse: emailResponse,
          currentMailboxId: emailFilter?.mailboxId,
        ),
      );
    } catch (e) {
      yield Left(GetAllEmailFailure(e));
    }
  }

  Either<Failure, Success> _toGetEmailState({
    required EmailsResponse emailResponse,
    MailboxId? currentMailboxId,
  }) {
    final presentationEmailList = emailResponse.emailList
      ?.map((email) => email.toPresentationEmail()).toList() ?? List.empty();

    return Right<Failure, Success>(GetAllEmailSuccess(
      emailList: presentationEmailList,
      currentEmailState: emailResponse.state,
      currentMailboxId: currentMailboxId));
  }
}