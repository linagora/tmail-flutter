import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';
import 'package:rich_text_composer/views/commons/logger.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleDownloadAttachmentExtension on ThreadDetailController {
  bool isDownloadAllEnabled(int countAttachments) {
    return session?.isDownloadAllSupported(accountId) == true &&
        countAttachments > 1;
  }

  void handleDownloadAttachment(Attachment attachment, EmailId emailIdOpened) {
    log('$runtimeType::handleDownloadAttachment: Attachment name is ${attachment.name},  Email id opened is $emailIdOpened');
    mailboxDashBoardController
      ..dispatchEmailUIAction(DownloadEmailAttachmentInThreadDetailAction(
          attachment,
          emailIdOpened,
        ))
      ..dispatchEmailUIAction(EmailUIAction());
  }

  void handleViewAttachment(
    AppLocalizations appLocalizations,
    Attachment attachment,
    EmailId emailIdOpened,
  ) {
    log('$runtimeType::handleViewAttachment: Attachment name is ${attachment.name},  Email id opened is $emailIdOpened');
    mailboxDashBoardController
      ..dispatchEmailUIAction(ViewEmailAttachmentInThreadDetailAction(
          appLocalizations,
          attachment,
          emailIdOpened,
        ))
      ..dispatchEmailUIAction(EmailUIAction());
  }

  void handleDownloadAllAttachmentsAction(EmailId emailIdOpened) {
    log('$runtimeType::handleDownloadAllAttachmentsAction: Email id opened is $emailIdOpened');
    mailboxDashBoardController
      ..dispatchEmailUIAction(DownloadAllEmailAttachmentInThreadDetailAction(
          emailIdOpened
        ))
      ..dispatchEmailUIAction(EmailUIAction());
  }
}
