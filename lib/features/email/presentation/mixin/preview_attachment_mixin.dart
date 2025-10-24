import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';
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
import 'package:tmail_ui_user/features/email/domain/state/download_and_get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_and_get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_html_content_from_upload_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/mixin/emit_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/html_attachment_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_viewer.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_dialog_view.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:twake_previewer_flutter/core/constants/supported_charset.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/previewer_state.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/top_bar_options.dart';
import 'package:twake_previewer_flutter/core/previewer_options/previewer_options.dart';
import 'package:twake_previewer_flutter/twake_image_previewer/twake_image_previewer.dart';
import 'package:twake_previewer_flutter/twake_plain_text_previewer/twake_plain_text_previewer.dart';

typedef OnPreviewOrDownloadAttachmentAction = void Function(
  Attachment attachment,
  bool isPreviewSupported,
);

mixin PreviewAttachmentMixin on EmitMixin {
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
    required BaseController controller,
    required ParseEmailByBlobIdInteractor parseEmailInteractor,
    required DownloadAndGetHtmlContentFromAttachmentInteractor downloadAndGetHtmlInteractor,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
  }) {
    if (PlatformInfo.isWeb && attachment.isPDFFile) {
      _previewPDFFile(
        context: context,
        attachment: attachment,
        accountId: accountId,
        session: session,
      );
    } else if (attachment.isEMLFile) {
      preparePreviewEMLFileAction(
        appLocalizations: AppLocalizations.of(context),
        accountId: accountId,
        blobId: attachment.blobId,
        controller: controller,
        parseEmailByBlobIdInteractor: parseEmailInteractor,
      );
    } else if (attachment.isHTMLFile) {
      _preparePreviewHtmlFileAction(
        appLocalizations: AppLocalizations.of(context),
        session: session,
        accountId: accountId,
        attachment: attachment,
        controller: controller,
        downloadAndGetHtmlInteractor: downloadAndGetHtmlInteractor,
        isDialogLoadingVisible: isDialogLoadingVisible,
      );
    } else {
      if (isDialogLoadingVisible) {
        SmartDialog.showLoading(
          msg: AppLocalizations.of(context).loadingPleaseWait,
          maskColor: Colors.black38,
        );
      }
      onPreviewOrDownloadAction(
        attachment,
        attachment.isPreviewSupported,
      );
    }
  }

  void previewUploadFileAction({
    required BuildContext context,
    required UploadFileState uploadFile,
    required AccountId? accountId,
    required Session? session,
    required BaseController controller,
    required ParseEmailByBlobIdInteractor parseEmailInteractor,
    required GetHtmlContentFromUploadFileInteractor getHtmlInteractor,
    required DownloadAndGetHtmlContentFromAttachmentInteractor downloadAndGetHtmlInteractor,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
  }) {
    final attachment = uploadFile.attachment!;

    if (PlatformInfo.isWeb && attachment.isPDFFile == true) {
      _previewPDFFile(
        context: context,
        attachment: attachment,
        accountId: accountId,
        session: session,
      );
      return;
    }

    if (attachment.isEMLFile == true) {
      preparePreviewEMLFileAction(
        appLocalizations: AppLocalizations.of(context),
        accountId: accountId,
        blobId: attachment.blobId,
        controller: controller,
        parseEmailByBlobIdInteractor: parseEmailInteractor,
      );
      return;
    }

    if (attachment.isHTMLFile == true) {
      if (uploadFile.file?.bytes != null) {
        _preparePreviewHtmlFileByUploadFile(
          appLocalizations: AppLocalizations.of(context),
          uploadFile: uploadFile,
          controller: controller,
          getHtmlInteractor: getHtmlInteractor,
          isDialogLoadingVisible: isDialogLoadingVisible,
        );
      } else {
        _preparePreviewHtmlFileAction(
          appLocalizations: AppLocalizations.of(context),
          attachment: attachment,
          accountId: accountId,
          session: session,
          controller: controller,
          downloadAndGetHtmlInteractor: downloadAndGetHtmlInteractor,
          isDialogLoadingVisible: isDialogLoadingVisible,
        );
      }
      return;
    }

    if (attachment.isImage == true && uploadFile.file?.bytes != null) {
      previewImageFileAction(
        attachment: attachment,
        imageBytes: uploadFile.file!.bytes!,
        context: currentContext,
        onDownloadAction: (attachment) =>
            onPreviewOrDownloadAction(attachment, false),
      );
      return;
    }

    if ((attachment.isText == true || attachment.isJson == true) &&
        uploadFile.file?.bytes != null) {
      previewPlainTextFileAction(
        attachment: attachment,
        fileBytes: uploadFile.file!.bytes!,
        context: currentContext,
        onDownloadAction: (attachment) =>
            onPreviewOrDownloadAction(attachment, false),
      );
      return;
    }

    if (uploadFile.file?.bytes != null) {
      downloadFileWebAction(
        fileName: attachment.generateFileName(),
        fileBytes: uploadFile.file!.bytes!,
      );
      return;
    }

    if (isDialogLoadingVisible) {
      SmartDialog.showLoading(
        msg: AppLocalizations.of(context).loadingPleaseWait,
        maskColor: Colors.black38,
      );
    }
    onPreviewOrDownloadAction(attachment, attachment.isPreviewSupported);
  }

  void downloadFileWebAction({
    required String fileName,
    required Uint8List fileBytes,
  }) {
    _downloadManager.createAnchorElementDownloadFileWeb(
      fileBytes,
      fileName,
    );
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

  void preparePreviewEMLFileAction({
    required AppLocalizations appLocalizations,
    required AccountId? accountId,
    required Id? blobId,
    required ParseEmailByBlobIdInteractor parseEmailByBlobIdInteractor,
    required BaseController controller,
  }) {
    SmartDialog.showLoading(
      msg: appLocalizations.loadingPleaseWait,
      maskColor: Colors.black38,
    );

    if (accountId == null) {
      emitFailure(
        controller: controller,
        failure: ParseEmailByBlobIdFailure(NotFoundAccountIdException()),
      );
      return;
    }

    if (blobId == null) {
      emitFailure(
        controller: controller,
        failure: ParseEmailByBlobIdFailure(NotFoundBlobIdException([])),
      );
      return;
    }

    controller.consumeState(
      parseEmailByBlobIdInteractor.execute(accountId, blobId),
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

  void _preparePreviewHtmlFileAction({
    required AppLocalizations appLocalizations,
    required Session? session,
    required AccountId? accountId,
    required Attachment attachment,
    required BaseController controller,
    required DownloadAndGetHtmlContentFromAttachmentInteractor downloadAndGetHtmlInteractor,
    bool isDialogLoadingVisible = false,
  }) {
    if (isDialogLoadingVisible) {
      SmartDialog.showLoading(
        msg: appLocalizations.loadingPleaseWait,
        maskColor: Colors.black38,
      );
    }

    final attachmentEvaluation = evaluateAttachment(
      accountId: accountId,
      session: session,
      attachment: attachment,
    );

    if (!attachmentEvaluation.canDownloadAttachment) {
      emitFailure(
        controller: controller,
        failure: DownloadAndGetHtmlContentFromAttachmentFailure(
          exception: null,
          attachment: attachment,
        ),
      );
      return;
    }

    controller.consumeState(
      downloadAndGetHtmlInteractor.execute(
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

  void _preparePreviewHtmlFileByUploadFile({
    required AppLocalizations appLocalizations,
    required UploadFileState uploadFile,
    required BaseController controller,
    required GetHtmlContentFromUploadFileInteractor getHtmlInteractor,
    bool isDialogLoadingVisible = false,
  }) {
    if (isDialogLoadingVisible) {
      SmartDialog.showLoading(
        msg: appLocalizations.loadingPleaseWait,
        maskColor: Colors.black38,
      );
    }
    controller.consumeState(getHtmlInteractor.execute(uploadFile));
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
      emitFailure(
        controller: controller,
        failure: PreviewEmailFromEmlFileFailure(NotFoundSessionException()),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: controller,
        failure: PreviewEmailFromEmlFileFailure(NotFoundAccountIdException()),
      );
      return;
    }

    if (context == null) {
      emitFailure(
        controller: controller,
        failure: PreviewEmailFromEmlFileFailure(NotFoundContextException()),
      );
      return;
    }

    try {
      controller.consumeState(previewInteractor.execute(
        PreviewEmailEMLRequest(
          accountId: accountId,
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
      emitFailure(
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

  void previewEMLFileAction({
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

  void handlePreviewHtmlFileFailure() {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).thisHtmlAttachmentCannotBePreviewed,
      );
    }
  }

  void previewImageFileAction({
    required Attachment attachment,
    required Uint8List imageBytes,
    required BuildContext? context,
    required OnDownloadAttachmentFileAction onDownloadAction,
  }) {
    log('$runtimeType::previewImageFileAction: Attachment blobId is ${attachment.blobId?.value}');
    if (context == null) return;

    Navigator.of(context).push(
      GetDialogRoute(
        pageBuilder: (context, _, __) => PointerInterceptor(
          child: TwakeImagePreviewer(
            bytes: imageBytes,
            zoomable: true,
            previewerOptions: const PreviewerOptions(
              previewerState: PreviewerState.success,
            ),
            topBarOptions: TopBarOptions(
              title: attachment.generateFileName(),
              onClose: () => Navigator.maybePop(context),
              onDownload: () => onDownloadAction(attachment),
            ),
          ),
        ),
        barrierDismissible: false,
      ),
    );
  }

  void previewPlainTextFileAction({
    required Attachment attachment,
    required Uint8List fileBytes,
    required BuildContext? context,
    required OnDownloadAttachmentFileAction onDownloadAction,
  }) {
    if (context == null) return;

    Navigator.of(context).push(
      GetDialogRoute(
        pageBuilder: (context, _, __) => PointerInterceptor(
          child: TwakePlainTextPreviewer(
            supportedCharset: SupportedCharset.utf8,
            bytes: fileBytes,
            previewerOptions: PreviewerOptions(
              previewerState: PreviewerState.success,
              width: context.width * 0.8,
            ),
            topBarOptions: TopBarOptions(
              title: attachment.generateFileName(),
              onClose: () => Navigator.maybePop(context),
              onDownload: () => onDownloadAction(attachment),
            ),
          ),
        ),
        barrierDismissible: false,
      ),
    );
  }

  void previewHtmlFileAction({
    required Attachment attachment,
    required String title,
    required String content,
    required OnMailtoDelegateAction openMailToLink,
    required OnDownloadAttachmentFileAction onDownloadAction,
    required ResponsiveUtils responsiveUtils,
  }) {
    Get.dialog(
      HtmlAttachmentPreviewer(
        title: title,
        htmlContent: content,
        mailToClicked: openMailToLink,
        downloadAttachmentClicked: () => onDownloadAction(attachment),
        responsiveUtils: responsiveUtils,
      ),
    );
  }

  Future<void> openEMLPreviewer({
    required BuildContext context,
    required BaseController controller,
    required ParseEmailByBlobIdInteractor parseEmailInteractor,
    required Uri? uri,
    required AccountId? accountId,
  }) async {
    if (uri == null) return;

    final blobId = uri.path;
    if (blobId.isEmpty) return;

    preparePreviewEMLFileAction(
      appLocalizations: AppLocalizations.of(context),
      accountId: accountId,
      blobId: Id(blobId),
      controller: controller,
      parseEmailByBlobIdInteractor: parseEmailInteractor,
    );
  }
}
