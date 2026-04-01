import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/add_list_label_to_list_email_state.dart';
import 'package:tmail_ui_user/features/labels/domain/model/add_list_labels_to_list_emails_params.dart';

class AddListLabelToListEmailsInteractor {
  final EmailRepository _emailRepository;

  AddListLabelToListEmailsInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    AddListLabelsToListEmailsParams params,
  ) async* {
    try {
      if (params.emailIds.isEmpty) {
        yield Left(AddListLabelsToListEmailsFailure(
          exception: EmailIdsSuccessIsEmptyException(),
          labelDisplays: params.labelDisplays,
        ));
        return;
      }
      yield Right(AddingListLabelsToListEmails());
      final result = await _emailRepository.addListLabelToListEmail(
        session,
        accountId,
        params.emailIds,
        params.labelKeywords,
      );
      if (params.emailIds.length == result.emailIdsSuccess.length) {
        yield Right(AddListLabelsToListEmailsSuccess(
          result.emailIdsSuccess,
          params.labelKeywords,
          params.labelDisplays,
          onSync: params.onSync,
        ));
      } else if (result.emailIdsSuccess.isEmpty) {
        yield Left(AddListLabelsToListEmailsFailure(
          exception: result.mapErrors.isNotEmpty
              ? SetMethodException(result.mapErrors)
              : EmailIdsSuccessIsEmptyException(),
          labelDisplays: params.labelDisplays,
        ));
      } else {
        yield Right(AddListLabelsToListEmailsHasSomeFailure(
          result.emailIdsSuccess,
          params.labelKeywords,
          params.labelDisplays,
          onSync: params.onSync,
        ));
      }
    } catch (e) {
      yield Left(AddListLabelsToListEmailsFailure(
        exception: e,
        labelDisplays: params.labelDisplays,
      ));
    }
  }
}
