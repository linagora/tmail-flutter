import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';

class GetEmailContentInteractor {
  final EmailRepository emailRepository;

  GetEmailContentInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final email = await emailRepository.getEmailContent(accountId, emailId);

      if (email.emailContentList.isNotEmpty) {
        final emailContent = email.emailContentList.first;
        if (emailContent.type == EmailContentType.textHtml) {
          final contentHtml = await emailRepository.transformEmailContentToHtml(emailContent);
          yield Right<Failure, Success>(GetEmailContentSuccess(
            EmailContent(emailContent.type, contentHtml),
            email.allAttachments));
        } else {
          yield Right<Failure, Success>(GetEmailContentSuccess(emailContent, email.allAttachments));
        }
      } else {
        yield Left(GetEmailContentFailure(null));
      }
    } catch (e) {
      yield Left(GetEmailContentFailure(e));
    }
  }
}