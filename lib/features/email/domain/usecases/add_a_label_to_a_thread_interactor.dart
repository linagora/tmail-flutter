import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_thread_state.dart';

class AddALabelToAThreadInteractor {
  final EmailRepository _emailRepository;

  AddALabelToAThreadInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
    String labelDisplay,
  ) async* {
    try {
      yield Right(AddingALabelToAThread());
      await _emailRepository.addLabelToThread(
        session,
        accountId,
        emailIds,
        labelKeyword,
      );
      yield Right(AddALabelToAThreadSuccess(
        emailIds,
        labelKeyword,
        labelDisplay,
      ));
    } catch (e) {
      yield Left(AddALabelToAThreadFailure(
        exception: e,
        labelDisplay: labelDisplay,
      ));
    }
  }
}
