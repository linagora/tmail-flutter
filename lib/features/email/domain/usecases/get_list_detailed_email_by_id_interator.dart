import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
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

class GetListDetailedEmailByIdInteractor {
  final EmailRepository _emailRepository;

  GetListDetailedEmailByIdInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    String baseDownloadUrl
  ) async* {
    try {
      yield Right<Failure, Success>(GetDetailedEmailByIdLoading());

      final ascendingEmailIds = emailIds.reversed.toList();
      Map<Email, DetailedEmail> mapDetailedEmails = {};

      for (var emailId in ascendingEmailIds) {
        final email = await _emailRepository.getDetailedEmailById(session, accountId, emailId);
        final tupleEmail = await _convertEmailToDetailedEmail(accountId, email, baseDownloadUrl);
        mapDetailedEmails[tupleEmail.value1] = tupleEmail.value2;
      }
      log('GetListDetailedEmailByIdInteractor::execute: mapDetailedEmails = ${mapDetailedEmails.length}');
      yield Right<Failure, Success>(GetDetailedEmailByIdSuccess(
        mapDetailedEmails,
        accountId,
        session,
      ));
    } catch (e) {
      yield Left<Failure, Success>(GetDetailedEmailByIdFailure(e));
    }
  }

  Future<Tuple2<Email, DetailedEmail>> _convertEmailToDetailedEmail(
    AccountId accountId,
    Email email,
    String baseDownloadUrl
  ) async {
    String? htmlEmailContent;

    final listEmailContent = email.emailContentList;
    if (listEmailContent.isNotEmpty) {
      final mapCidImageDownloadUrl = email.attachmentsWithCid.toMapCidImageDownloadUrl(
        accountId: accountId,
        downloadUrl: baseDownloadUrl
      );
      TransformConfiguration transformConfiguration = TransformConfiguration.forPreviewEmail();
      if (email.isDraft) {
        transformConfiguration = TransformConfiguration.forDraftsEmail();
      } else if (PlatformInfo.isWeb) {
        transformConfiguration = TransformConfiguration.forPreviewEmailOnWeb();
      }
      final newEmailContents = await _emailRepository.transformEmailContent(
        email.emailContentList,
        mapCidImageDownloadUrl,
        transformConfiguration
      );

      htmlEmailContent = newEmailContents.asHtmlString;
    }

    final detailedEmail = email.toDetailedEmail(htmlEmailContent: htmlEmailContent);

    return Tuple2(email, detailedEmail);
  }
}