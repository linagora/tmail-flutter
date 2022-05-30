import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';

class SaveEmailAsDraftsInteractor {
  final EmailRepository emailRepository;

  SaveEmailAsDraftsInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, Email email) async* {
    try {
      yield Right<Failure, Success>(SaveEmailAsDraftsLoading());
      final emailAsDrafts = await emailRepository.saveEmailAsDrafts(accountId, email);
      if (emailAsDrafts != null) {
        yield Right<Failure, Success>(SaveEmailAsDraftsSuccess(emailAsDrafts));
      } else {
        yield Left<Failure, Success>(SaveEmailAsDraftsFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(SaveEmailAsDraftsFailure(e));
    }
  }
}