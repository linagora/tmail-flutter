import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';

class DeleteEmailPermanentlyInteractor {
  final EmailRepository _emailRepository;

  DeleteEmailPermanentlyInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, EmailId emailId) async* {
    try {
      yield Right<Failure, Success>(StartDeleteEmailPermanently());
      final result = await _emailRepository.deleteEmailPermanently(session, accountId, emailId);
      if (result) {
        yield Right<Failure, Success>(DeleteEmailPermanentlySuccess());
      } else {
        yield Left<Failure, Success>(DeleteEmailPermanentlyFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteEmailPermanentlyFailure(e));
    }
  }
}