import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/email_extension.dart';

class GetEmailContentInteractor {
  final EmailRepository emailRepository;

  GetEmailContentInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId) async* {
    try {
      yield Right<Failure, Success>(UIState.loading);
      final email = await emailRepository.getEmailContent(accountId, emailId);
      yield Right<Failure, Success>(GetEmailContentSuccess(email.toEmailContent()));
    } catch (e) {
      yield Left(GetEmailContentFailure(e));
    }
  }
}