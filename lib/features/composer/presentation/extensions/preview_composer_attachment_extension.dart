import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension PreviewComposerAttachmentExtension on ComposerController {
  void previewAttachment(BuildContext context, UploadTaskId uploadId) {
    final uploadFile = uploadController.getUploadFileId(uploadId);

    if (uploadFile == null || uploadFile.attachment == null) {
      appToast.showToastWarningMessage(
        context,
        AppLocalizations.of(context).noPreviewAvailable,
      );
      return;
    }

    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    previewUploadFileAction(
      context: context,
      uploadFile: uploadFile,
      accountId: accountId,
      session: session,
      controller: this,
      isDialogLoadingVisible: true,
      parseEmailInteractor: parseEmailByBlobIdInteractor,
      getHtmlInteractor: getHtmlContentFromUploadFileInteractor,
      downloadAndGetHtmlInteractor: downloadAndGetHtmlContentFromAttachmentInteractor,
      onPreviewOrDownloadAction: (attachment, isPreview) {
        downloadAttachment(
          attachment: attachment,
          isPreviewSupported: isPreview,
        );
      },
    );
  }

  Future<void> openMailToLink(Uri? uri) async {
    if (uri == null) return;

    final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(
      uri.toString(),
    );

    if (!RouteUtils.canOpenComposerFromNavigationRouter(navigationRouter)) {
      return;
    }

    mailboxDashBoardController.openComposer(
      ComposerArguments.fromMailtoUri(
        listEmailAddress: navigationRouter.listEmailAddress,
        cc: navigationRouter.cc,
        bcc: navigationRouter.bcc,
        subject: navigationRouter.subject,
        body: navigationRouter.body,
      ),
    );
  }

  void downloadAttachment({
    required Attachment attachment,
    bool isPreviewSupported = false,
  }) {
    log('$runtimeType::downloadAttachment: Attachment blobId is ${attachment.blobId?.value}');
    if (PlatformInfo.isWeb) {
      downloadAttachmentForWeb(
        attachment: attachment,
        accountId: mailboxDashBoardController.accountId.value,
        session: mailboxDashBoardController.sessionCurrent,
        controller: this,
        previewerSupported: isPreviewSupported,
        downloadInteractor: downloadAttachmentForWebInteractor,
      );
    } else {
      if (SmartDialog.checkExist()) {
        SmartDialog.dismiss();
      }
      log('$runtimeType::previewAttachment: Platform is not supported');
    }
  }

  void previewEML(Uri? uri) {
    if (currentContext != null) {
      openEMLPreviewer(
        context: currentContext!,
        uri: uri,
        accountId: mailboxDashBoardController.accountId.value,
        controller: this,
        parseEmailInteractor: parseEmailByBlobIdInteractor,
      );
    }
  }

  void downloadAttachmentForWebSuccessAction(
    DownloadAttachmentForWebSuccess success,
  ) {
    if (SmartDialog.checkExist()) {
      SmartDialog.dismiss();
    }

    if (!success.previewerSupported) {
      downloadFileWebAction(
        fileName: success.attachment.generateFileName(),
        fileBytes: success.bytes,
      );
      return;
    }

    if (success.attachment.isImage) {
      previewImageFileAction(
        attachment: success.attachment,
        imageBytes: success.bytes,
        context: currentContext,
        onDownloadAction: (attachment) =>
            downloadAttachment(attachment: attachment),
      );
    } else if (success.attachment.isText || success.attachment.isJson) {
      previewPlainTextFileAction(
        attachment: success.attachment,
        fileBytes: success.bytes,
        context: currentContext,
        onDownloadAction: (attachment) =>
            downloadAttachment(attachment: attachment),
      );
    } else {
      log('$runtimeType::previewAttachment: Platform is not supported');
    }
  }
}
