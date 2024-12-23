import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';

class RemoveEmailDraftsInteractor {
  final EmailRepository _emailRepository;

  RemoveEmailDraftsInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, EmailId emailId) async* {
    try {
      final result = await _emailRepository.removeEmailDrafts(session, accountId, emailId);
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