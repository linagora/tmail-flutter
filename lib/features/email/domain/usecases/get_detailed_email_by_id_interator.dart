import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:model/extensions/list_email_content_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_detailed_email_by_id_state.dart';

class GetDetailedEmailByIdInteractor {
  final EmailRepository _emailRepository;

  GetDetailedEmailByIdInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    String? baseDownloadUrl
  ) async* {
    try {
      yield Right<Failure, Success>(GetDetailedEmailByIdLoading());

      final email = await _emailRepository.getDetailedEmailById(session, accountId, emailId);

      final parsedEmail = await _parsingEmailToDetailedEmail(accountId, email, baseDownloadUrl);

      yield Right<Failure, Success>(GetDetailedEmailByIdSuccess(
        parsedEmail.value1,
        parsedEmail.value2,
        accountId,
        session,
      ));
    } catch (e) {
      yield Left<Failure, Success>(GetDetailedEmailByIdFailure(e));
    }
  }

  Future<Tuple2<Email, DetailedEmail>> _parsingEmailToDetailedEmail(
    AccountId accountId,
    Email email,
    String? baseDownloadUrl
  ) async {
    String? htmlEmailContent;

    final listEmailContent = email.emailContentList;
    if (listEmailContent.isNotEmpty) {
      final newEmailContents = await _emailRepository.transformEmailContent(
        listEmailContent,
        email.allAttachments.listAttachmentsDisplayedInContent,
        baseDownloadUrl,
        accountId);

      htmlEmailContent = newEmailContents.asHtmlString;
    }

    final detailedEmail = email.toDetailedEmail(htmlEmailContent: htmlEmailContent);

    return Tuple2(email, detailedEmail);
  }
}