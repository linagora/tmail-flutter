import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/download_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/preview_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_download_attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension HandlePreviewAttachmentExtension on MailboxDashBoardController {
  void previewAttachment({
    required BuildContext context,
    required Attachment attachment,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
    DownloadSourceView? sourceView,
  }) =>
      downloadController.previewAttachment(
        context: context,
        attachment: attachment,
        accountId: accountId.value,
        session: sessionCurrent,
        ownEmailAddress: ownEmailAddress.value,
        sourceView: sourceView,
        onPreviewOrDownloadAction: onPreviewOrDownloadAction,
        isDialogLoadingVisible: isDialogLoadingVisible,
      );

  void previewUploadFile({
    required BuildContext context,
    required UploadFileState uploadFile,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
  }) =>
      downloadController.previewUploadFile(
        context: context,
        uploadFile: uploadFile,
        accountId: accountId.value,
        session: sessionCurrent,
        ownEmailAddress: ownEmailAddress.value,
        onPreviewOrDownloadAction: onPreviewOrDownloadAction,
        isDialogLoadingVisible: isDialogLoadingVisible,
      );

  void showDialogToPreviewEMLAttachment({
    required BuildContext context,
    required EMLPreviewer emlPreviewer,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentFileAction onDownloadFileAction,
  }) =>
      downloadController.showDialogToPreviewEMLAttachment(
        context: context,
        emlPreviewer: emlPreviewer,
        onMailtoAction: onMailtoAction,
        onPreviewAction: (uri) => downloadController.openEMLPreviewer(
          appLocalizations: AppLocalizations.of(context),
          uri: uri,
          accountId: accountId.value,
          session: sessionCurrent,
          ownEmailAddress: ownEmailAddress.value,
        ),
        onDownloadAction: (uri) async => downloadController.downloadAttachmentInEMLPreview(
          uri: uri,
          onDownloadAction: (attachment) => downloadAttachment(
            attachment: attachment,
          )
        ),
      );

  void openComposerFromMailToLink(Uri uri) {
    final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(
      uri.toString(),
    );
    log('$runtimeType::openComposerFromMailToLink(): ${uri.toString()}');
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
