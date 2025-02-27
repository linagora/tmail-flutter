
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_email_searched_to_folder_state.dart';

class MoveAllEmailSearchedToFolderInteractor {

  final ThreadRepository threadRepository;

  MoveAllEmailSearchedToFolderInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MailboxId destinationMailboxId,
    String destinationPath,
    SearchEmailFilter searchEmailFilter,
    {
      bool isDestinationSpamMailbox = false,
      EmailFilterCondition? moreFilterCondition
    }
  ) async* {
    try {
      yield Right(MoveAllEmailSearchedToFolderLoading());
      final listEmailId = await threadRepository.moveAllEmailSearchedToFolder(
        session,
        accountId,
        destinationMailboxId,
        destinationPath,
        searchEmailFilter,
        isDestinationSpamMailbox: isDestinationSpamMailbox,
        moreFilterCondition: moreFilterCondition,
      );
      yield Right(MoveAllEmailSearchedToFolderSuccess(listEmailId, destinationPath));
    } catch (e) {
      yield Left(MoveAllEmailSearchedToFolderFailure(destinationPath, e));
    }
  }
}