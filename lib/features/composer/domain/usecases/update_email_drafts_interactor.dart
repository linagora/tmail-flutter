import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';

class UpdateEmailDraftsInteractor {
  final EmailRepository emailRepository;

  UpdateEmailDraftsInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, Email newEmail, EmailId oldEmailId) async* {
    try {
      final newEmailDrafts = await emailRepository.updateEmailDrafts(accountId, newEmail, oldEmailId);
      if (newEmailDrafts != null) {
        yield Right<Failure, Success>(UpdateEmailDraftsSuccess(newEmailDrafts));
      } else {
        yield Left<Failure, Success>(UpdateEmailDraftsFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(UpdateEmailDraftsFailure(e));
    }
  }
}