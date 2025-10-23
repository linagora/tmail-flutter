import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_viewer.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_dialog_view.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

typedef OnDownloadAttachmentAction = void Function(Attachment attachment);

mixin PreviewAttachmentMixin {
  final DownloadManager _downloadManager = Get.find<DownloadManager>();
  final PrintUtils _printUtils = Get.find<PrintUtils>();
  final AppToast _appToast = Get.find<AppToast>();
  final ToastManager _toastManager = Get.find<ToastManager>();
  final DynamicUrlInterceptors _dynamicUrlInterceptors =
      Get.find<DynamicUrlInterceptors>();

  void previewAttachmentAction({
    required BuildContext context,
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
    required BaseController controller,
    required ParseEmailByBlobIdInteractor parseEmailInteractor,
    required GetHtmlContentFromAttachmentInteractor getHtmlInteractor,
    required OnDownloadAttachmentAction onDownloadAttachment,
  }) {
    if (PlatformInfo.isWeb && attachment.isPDFFile) {
      _previewPDFFile(
        context: context,
        attachment: attachment,
        accountId: accountId,
        session: session,
      );
    } else if (attachment.isEMLFile) {
      previewEMLFileAction(
        appLocalizations: AppLocalizations.of(context),
        accountId: accountId,
        session: session,
        ownEmailAddress: ownEmailAddress,
        blobId: attachment.blobId,
        controller: controller,
        parseEmailByBlobIdInteractor: parseEmailInteractor,
      );
    } else if (attachment.isHTMLFile) {
      _previewHtmlFileAction(
        session: session,
        accountId: accountId,
        attachment: attachment,
        controller: controller,
        getHtmlInteractor: getHtmlInteractor,
      );
    } else {
      onDownloadAttachment(attachment);
    }
  }

  Future<void> _previewPDFFile({
    required BuildContext context,
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
  }) async {
    if (accountId == null || session == null) {
      _appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).noPreviewAvailable,
      );
      return;
    }

    try {
      final downloadUrl = session.getDownloadUrl(
        jmapUrl: _dynamicUrlInterceptors.jmapUrl,
      );

      await Get.generalDialog(
        barrierColor: Colors.black.withValues(alpha: 0.8),
        pageBuilder: (_, __, ___) {
          return PointerInterceptor(
            child: PDFViewer(
              attachment: attachment,
              accountId: accountId,
              downloadUrl: downloadUrl,
              downloadAction: _downloadPDFFile,
              printAction: _printPDFFile,
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        _appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).noPreviewAvailable,
        );
      }
    }
  }

  void _downloadPDFFile(Uint8List bytes, String fileName) {
    _downloadManager.createAnchorElementDownloadFileWeb(bytes, fileName);
  }

  Future<void> _printPDFFile(Uint8List bytes, String fileName) async {
    await _printUtils.printPDFFile(bytes, fileName);
  }

  void previewEMLFileAction({
    required AppLocalizations appLocalizations,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
    required Id? blobId,
    required ParseEmailByBlobIdInteractor parseEmailByBlobIdInteractor,
    required BaseController controller,
  }) {
    SmartDialog.showLoading(
      msg: appLocalizations.loadingPleaseWait,
      maskColor: Colors.black38,
    );

    if (session == null) {
      _emitFailure(
        controller: controller,
        failure: ParseEmailByBlobIdFailure(NotFoundSessionException()),
      );
      return;
    }

    if (accountId == null) {
      _emitFailure(
        controller: controller,
        failure: ParseEmailByBlobIdFailure(NotFoundAccountIdException()),
      );
      return;
    }

    if (blobId == null) {
      _emitFailure(
        controller: controller,
        failure: ParseEmailByBlobIdFailure(NotFoundBlobIdException([])),
      );
      return;
    }

    controller.consumeState(
      parseEmailByBlobIdInteractor.execute(
        accountId,
        session,
        ownEmailAddress,
        blobId,
      ),
    );
  }

  ({
    bool canDownloadAttachment,
    AccountId? accountId,
    String? downloadUrl,
    Id? blobId,
  }) evaluateAttachment({
    required Session? session,
    required AccountId? accountId,
    required Attachment attachment,
  }) {
    String? downloadUrl;
    try {
      downloadUrl = session?.getDownloadUrl(
        jmapUrl: _dynamicUrlInterceptors.jmapUrl,
      );
    } catch (e) {
      downloadUrl = null;
    }
    final blobId = attachment.blobId;

    if (accountId == null || downloadUrl == null || blobId == null) {
      return (
        canDownloadAttachment: false,
        accountId: accountId,
        downloadUrl: downloadUrl,
        blobId: blobId,
      );
    }

    return (
      canDownloadAttachment: true,
      accountId: accountId,
      downloadUrl: downloadUrl,
      blobId: blobId,
    );
  }

  void _previewHtmlFileAction({
    required Session? session,
    required AccountId? accountId,
    required Attachment attachment,
    required BaseController controller,
    required GetHtmlContentFromAttachmentInteractor getHtmlInteractor,
  }) {
    final attachmentEvaluation = evaluateAttachment(
      accountId: accountId,
      session: session,
      attachment: attachment,
    );

    if (!attachmentEvaluation.canDownloadAttachment) {
      _emitFailure(
        controller: controller,
        failure: GetHtmlContentFromAttachmentFailure(
          exception: null,
          attachment: attachment,
        ),
      );
      return;
    }

    controller.consumeState(
      getHtmlInteractor.execute(
        attachmentEvaluation.accountId!,
        attachment,
        DownloadTaskId(attachmentEvaluation.blobId!.value),
        attachmentEvaluation.downloadUrl!,
        TransformConfiguration.create(
          customDomTransformers: [SanitizeHyperLinkTagInHtmlTransformer()],
          customTextTransformers: [
            const StandardizeHtmlSanitizingTransformers()
          ],
        ),
      ),
    );
  }

  void _emitFailure({
    required BaseController controller,
    required FeatureFailure failure,
  }) {
    controller.consumeState(Stream.value(Left(failure)));
  }

  void handleParseEmailByBlobIdSuccess({
    required BuildContext? context,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
    required Id blobId,
    required Email email,
    required BaseController controller,
    required PreviewEmailFromEmlFileInteractor previewInteractor,
  }) {
    if (session == null) {
      _emitFailure(
        controller: controller,
        failure: PreviewEmailFromEmlFileFailure(NotFoundSessionException()),
      );
      return;
    }

    if (accountId == null) {
      _emitFailure(
        controller: controller,
        failure: PreviewEmailFromEmlFileFailure(NotFoundAccountIdException()),
      );
      return;
    }

    if (context == null) {
      _emitFailure(
        controller: controller,
        failure: PreviewEmailFromEmlFileFailure(NotFoundContextException()),
      );
      return;
    }

    try {
      controller.consumeState(previewInteractor.execute(
        PreviewEmailEMLRequest(
          accountId: accountId,
          session: session,
          ownEmailAddress: ownEmailAddress,
          blobId: blobId,
          email: email,
          locale: Localizations.localeOf(context),
          appLocalizations: AppLocalizations.of(context),
          baseDownloadUrl: session.getDownloadUrl(
            jmapUrl: _dynamicUrlInterceptors.jmapUrl,
          ),
        ),
      ));
    } catch (e) {
      _emitFailure(
        controller: controller,
        failure: PreviewEmailFromEmlFileFailure(e),
      );
    }
  }

  void handleParseEmailByBlobIdFailure(ParseEmailByBlobIdFailure failure) {
    SmartDialog.dismiss();
    _toastManager.showMessageFailure(failure);
  }

  void handlePreviewEmailFromEMLFileFailure(
    PreviewEmailFromEmlFileFailure failure,
  ) {
    SmartDialog.dismiss();
    _toastManager.showMessageFailure(failure);
  }

  void handlePreviewEmailFromEMLFileSuccess({
    required EMLPreviewer emlPreviewer,
    required BuildContext? context,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentDelegateAction onDownloadAction,
    required OnPreviewEMLDelegateAction onPreviewAction,
  }) {
    SmartDialog.dismiss();

    if (PlatformInfo.isWeb) {
      bool isOpen = HtmlUtils.openNewWindowByUrl(
        RouteUtils.createUrlWebLocationBar(
          AppRoutes.emailEMLPreviewer,
          previewId: emlPreviewer.id,
        ).toString(),
      );

      if (!isOpen) {
        _toastManager.showMessageFailure(
          PreviewEmailFromEmlFileFailure(CannotOpenNewWindowException()),
        );
      }
    } else if (PlatformInfo.isMobile) {
      if (context == null) {
        _toastManager.showMessageFailure(
          PreviewEmailFromEmlFileFailure(NotFoundContextException()),
        );
        return;
      }

      if (PlatformInfo.isAndroid) {
        showModalSheetToPreviewEMLAttachment(
          context: context,
          emlPreviewer: emlPreviewer,
          imagePaths: imagePaths,
          onMailtoAction: onMailtoAction,
          onDownloadAction: onDownloadAction,
          onPreviewAction: onPreviewAction,
        );
      } else if (PlatformInfo.isIOS) {
        showDialogToPreviewEMLAttachment(
          context: context,
          emlPreviewer: emlPreviewer,
          imagePaths: imagePaths,
          onMailtoAction: onMailtoAction,
          onDownloadAction: onDownloadAction,
          onPreviewAction: onPreviewAction,
        );
      }
    }
  }

  void showModalSheetToPreviewEMLAttachment({
    required BuildContext context,
    required EMLPreviewer emlPreviewer,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentDelegateAction onDownloadAction,
    required OnPreviewEMLDelegateAction onPreviewAction,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0,
          builder: (context, ___) => EmailPreviewerDialogView(
            emlPreviewer: emlPreviewer,
            imagePaths: imagePaths,
            onMailtoDelegateAction: onMailtoAction,
            onPreviewEMLDelegateAction: onPreviewAction,
            onDownloadAttachmentDelegateAction: onDownloadAction,
          ),
        );
      },
    );
  }

  void showDialogToPreviewEMLAttachment({
    required BuildContext context,
    required EMLPreviewer emlPreviewer,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentDelegateAction onDownloadAction,
    required OnPreviewEMLDelegateAction onPreviewAction,
  }) {
    Get.dialog(
      EmailPreviewerDialogView(
        emlPreviewer: emlPreviewer,
        imagePaths: imagePaths,
        onMailtoDelegateAction: onMailtoAction,
        onPreviewEMLDelegateAction: onPreviewAction,
        onDownloadAttachmentDelegateAction: onDownloadAction,
      ),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }
}
