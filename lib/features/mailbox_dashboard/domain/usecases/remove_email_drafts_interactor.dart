import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';

class RemoveEmailDraftsInteractor {
  final EmailRepository emailRepository;

  RemoveEmailDraftsInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId) async* {
    try {
      final result = await emailRepository.removeEmailDrafts(accountId, emailId);
      if (result) {
        yield Right<Failure, Success>(RemoveEmailDraftsSuccess());
      } else {
        yield Left<Failure, Success>(RemoveEmailDraftsFailure(result));
      }
    } catch (e) {
      yield Left<Failure, Success>(RemoveEmailDraftsFailure(e));
    }
  }
}