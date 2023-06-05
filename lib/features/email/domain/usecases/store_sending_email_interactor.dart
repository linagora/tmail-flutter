import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_sending_email_state.dart';

class StoreSendingEmailInteractor {
  final EmailRepository _emailRepository;

  StoreSendingEmailInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    SendingEmail sendingEmail,
    bool isUpdateSendingEmail
  ) async* {
    try {
      yield Right<Failure, Success>(StoreSendingEmailLoading());
      await _emailRepository.storeSendingEmail(accountId, userName, sendingEmail, isUpdateSendingEmail);
      yield Right<Failure, Success>(StoreSendingEmailSuccess(sendingEmail, isUpdateSendingEmail));
    } catch (e) {
      yield Left<Failure, Success>(StoreSendingEmailFailure(e));
    }
  }
}