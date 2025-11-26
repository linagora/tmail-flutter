import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
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
    AccountId accountId, {
    UnsignedInt? limit,
    Set<Comparator>? sort,
    EmailFilter? emailFilter,
    Properties? propertiesCreated,
    Properties? propertiesUpdated,
    bool getLatestChanges = true,
    bool forceEmailQuery = false,
  }) async* {
    try {
      yield Right(GetAllEmailLoading());

      final Stream<EmailsResponse> sourceStream = forceEmailQuery
          ? threadRepository.forceQueryAllEmailsForWeb(
              session: session,
              accountId: accountId,
              limit: limit,
              sort: sort,
              emailFilter: emailFilter,
              propertiesCreated: propertiesCreated,
            )
          : threadRepository.getAllEmail(
              session,
              accountId,
              limit: limit,
              sort: sort,
              emailFilter: emailFilter,
              propertiesCreated: propertiesCreated,
              propertiesUpdated: propertiesUpdated,
              getLatestChanges: getLatestChanges,
            );

      yield* sourceStream.map(
        (emailResponse) => _toGetEmailState(
          emailResponse: emailResponse,
          currentMailboxId: emailFilter?.mailboxId,
        ),
      );
    } catch (error, stack) {
      logError(
        'GetEmailsInMailboxInteractor::execute() - Unexpected exception: $error, stack: $stack',
      );
      yield Left(GetAllEmailFailure(error));
    }
  }

  Either<Failure, Success> _toGetEmailState({
    required EmailsResponse emailResponse,
    required MailboxId? currentMailboxId,
  }) {
    final emailList =
        emailResponse.emailList?.map((e) => e.toPresentationEmail()).toList() ??
            const <PresentationEmail>[];

    return Right(
      GetAllEmailSuccess(
        emailList: emailList,
        currentEmailState: emailResponse.state,
        currentMailboxId: currentMailboxId,
      ),
    );
  }
}
