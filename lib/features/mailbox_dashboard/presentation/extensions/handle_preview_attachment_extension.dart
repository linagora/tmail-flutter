import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/mixin/preview_attachment_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension HandlePreviewAttachmentExtension on MailboxDashBoardController {
  void previewAttachmentAction({
    required BuildContext context,
    required Attachment attachment,
    required OnDownloadAttachmentAction onDownloadAttachment,
  }) =>
      downloadController.previewAttachmentAction(
        context: context,
        attachment: attachment,
        accountId: accountId.value,
        session: sessionCurrent,
        ownEmailAddress: ownEmailAddress.value,
        controller: downloadController,
        parseEmailInteractor: downloadController.parseEmailByBlobIdInteractor,
        getHtmlInteractor:
            downloadController.getHtmlContentFromAttachmentInteractor,
        onDownloadAttachment: onDownloadAttachment,
      );

  void previewEMLFileAction({
    required AppLocalizations appLocalizations,
    required Id? blobId,
  }) =>
      downloadController.previewEMLFileAction(
        appLocalizations: appLocalizations,
        accountId: accountId.value,
        session: sessionCurrent,
        ownEmailAddress: ownEmailAddress.value,
        blobId: blobId,
        controller: downloadController,
        parseEmailByBlobIdInteractor:
            downloadController.parseEmailByBlobIdInteractor,
      );

  void showDialogToPreviewEMLAttachment({
    required BuildContext context,
    required EMLPreviewer emlPreviewer,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentDelegateAction onDownloadAction,
    required OnPreviewEMLDelegateAction onPreviewAction,
  }) =>
      downloadController.showDialogToPreviewEMLAttachment(
        context: context,
        emlPreviewer: emlPreviewer,
        imagePaths: imagePaths,
        onMailtoAction: onMailtoAction,
        onDownloadAction: onDownloadAction,
        onPreviewAction: onPreviewAction,
      );

  Future<void> openMailToLink(Uri? uri) async {
    if (uri == null) return;
    final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(
      uri.toString(),
    );
    log('$runtimeType::openMailToLink(): ${uri.toString()}');
    if (!RouteUtils.canOpenComposerFromNavigationRouter(navigationRouter)) {
      return;
    }

    openComposer(ComposerArguments.fromMailtoUri(
      listEmailAddress: navigationRouter.listEmailAddress,
      cc: navigationRouter.cc,
      bcc: navigationRouter.bcc,
      subject: navigationRouter.subject,
      body: navigationRouter.body,
    ));
  }
}
