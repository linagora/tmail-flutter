import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/remove_a_label_from_an_thread_state.dart';

class RemoveALabelFromAThreadInteractor {
  final EmailRepository _emailRepository;

  RemoveALabelFromAThreadInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
    String labelDisplay,
  ) async* {
    try {
      yield Right(RemovingALabelFromAThread());
      await _emailRepository.removeLabelFromThread(
        session,
        accountId,
        emailIds,
        labelKeyword,
      );
      yield Right(RemoveALabelFromAThreadSuccess(
        emailIds,
        labelKeyword,
        labelDisplay,
      ));
    } catch (e) {
      yield Left(RemoveALabelFromAThreadFailure(
        exception: e,
        labelDisplay: labelDisplay,
      ));
    }
  }
}
