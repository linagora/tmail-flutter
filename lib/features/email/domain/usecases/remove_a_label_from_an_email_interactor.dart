import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/remove_a_label_from_an_email_state.dart';

class RemoveALabelFromAnEmailInteractor {
  final EmailRepository _emailRepository;

  RemoveALabelFromAnEmailInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
    String labelDisplay,
  ) async* {
    try {
      yield Right(RemovingALabelFromAnEmail());
      await _emailRepository.removeLabelFromEmail(
        session,
        accountId,
        emailId,
        labelKeyword,
      );
      yield Right(RemoveALabelFromAnEmailSuccess(
        emailId,
        labelKeyword,
        labelDisplay,
      ));
    } catch (e) {
      yield Left(RemoveALabelFromAnEmailFailure(
        exception: e,
        labelDisplay: labelDisplay,
      ));
    }
  }
}
