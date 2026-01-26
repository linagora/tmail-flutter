import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/remove_a_label_from_a_thread_state.dart';

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
      final result = await _emailRepository.removeLabelFromThread(
        session,
        accountId,
        emailIds,
        labelKeyword,
      );
      if (emailIds.length == result.emailIdsSuccess.length) {
        yield Right(RemoveALabelFromAThreadSuccess(
          result.emailIdsSuccess,
          labelKeyword,
          labelDisplay,
        ));
      } else if (result.emailIdsSuccess.isEmpty) {
        yield Left(RemoveALabelFromAThreadFailure(
          exception: EmailIdListIsEmptyException(),
          labelDisplay: labelDisplay,
        ));
      } else {
        yield Right(RemoveALabelFromAThreadHasSomeFailure(
          result.emailIdsSuccess,
          labelKeyword,
          labelDisplay,
        ));
      }
    } catch (e) {
      yield Left(RemoveALabelFromAThreadFailure(
        exception: e,
        labelDisplay: labelDisplay,
      ));
    }
  }
}
