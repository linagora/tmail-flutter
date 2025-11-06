import 'package:core/domain/exceptions/web_session_exception.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/dom/sanitize_hyper_link_tag_in_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
import 'package:tmail_ui_user/features/download/domain/exceptions/download_attachment_exceptions.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_and_get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/get_html_content_from_upload_file_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/download_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/html_attachment_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_viewer.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_dialog_view.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
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

extension PreviewAttachmentDownloadControllerExtension on DownloadController {
  void previewAttachment({
    required BuildContext context,
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
    DownloadSourceView? sourceView,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    if (PlatformInfo.isWeb && attachment.isPDFFile) {
      _previewPDFFile(
        context: context,
        attachment: attachment,
        accountId: accountId,
        session: session,
      );
    } else if (attachment.isEMLFile) {
      _preparePreviewEMLFile(
        appLocalizations: appLocalizations,
        accountId: accountId,
        session: session,
        ownEmailAddress: ownEmailAddress,
        blobId: attachment.blobId,
      );
    } else if (attachment.isHTMLFile) {
      _preparePreviewHtmlFile(
        appLocalizations: appLocalizations,
        session: session,
        accountId: accountId,
        attachment: attachment,
        isDialogLoadingVisible: isDialogLoadingVisible,
        sourceView: sourceView,
      );
    } else {
      if (isDialogLoadingVisible) {
        showDialogLoading(appLocalizations);
      }
      onPreviewOrDownloadAction(
        attachment,
        attachment.isPreviewSupported,
      );
    }
  }

  void previewUploadFile({
    required BuildContext context,
    required UploadFileState uploadFile,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
  }) {
    final attachment = uploadFile.attachment;
    final appLocalizations = AppLocalizations.of(context);

    if (attachment == null) {
      showPreviewNotAvailableToastMessage(context);
      return;
    }

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
      _preparePreviewEMLFile(
        appLocalizations: appLocalizations,
        accountId: accountId,
        session: session,
        ownEmailAddress: ownEmailAddress,
        blobId: attachment.blobId,
      );
      return;
    }

    if (attachment.isHTMLFile == true) {
      if (uploadFile.file?.bytes != null) {
        _preparePreviewHtmlFileByUploadFile(
          appLocalizations: appLocalizations,
          uploadFile: uploadFile,
          accountId: accountId,
          session: session,
          isDialogLoadingVisible: isDialogLoadingVisible,
        );
      } else {
        _preparePreviewHtmlFile(
          appLocalizations: appLocalizations,
          attachment: attachment,
          accountId: accountId,
          session: session,
          isDialogLoadingVisible: isDialogLoadingVisible,
        );
      }
      return;
    }

    if (attachment.isImage == true && uploadFile.file?.bytes != null) {
      previewImageFile(
        fileName: attachment.generateFileName(),
        imageBytes: uploadFile.file!.bytes!,
        context: context,
        onDownloadWebFileAction: (fileName, fileBytes) => downloadFileWeb(
          fileName: fileName,
          fileBytes: fileBytes,
        ),
      );
      return;
    }

    if ((attachment.isText == true || attachment.isJson == true) &&
        uploadFile.file?.bytes != null) {
      previewPlainTextFile(
        fileName: attachment.generateFileName(),
        fileBytes: uploadFile.file!.bytes!,
        context: context,
        onDownloadWebFileAction: (fileName, fileBytes) => downloadFileWeb(
          fileName: fileName,
          fileBytes: fileBytes,
        ),
      );
      return;
    }

    if (uploadFile.file?.bytes != null) {
      downloadFileWeb(
        fileName: attachment.generateFileName(),
        fileBytes: uploadFile.file!.bytes!,
      );
      return;
    }

    if (isDialogLoadingVisible) {
      showDialogLoading(appLocalizations);
    }
    onPreviewOrDownloadAction(attachment, attachment.isPreviewSupported);
  }

  Future<void> _previewPDFFile({
    required BuildContext context,
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
  }) async {
    final downloadUrl = session?.getSafetyDownloadUrl(
      jmapUrl: dynamicUrlInterceptors.jmapUrl,
    );

    if (accountId == null || session == null || downloadUrl == null) {
      showPreviewNotAvailableToastMessage(context);
      return;
    }

    await Get.generalDialog(
      barrierColor: Colors.black.withValues(alpha: 0.8),
      pageBuilder: (_, __, ___) {
        return PointerInterceptor(
          child: PDFViewer(
            attachment: attachment,
            accountId: accountId,
            downloadUrl: downloadUrl,
            downloadAction: (bytes, name) =>
                downloadFileWeb(fileName: name, fileBytes: bytes),
            printAction: printUtils.printPDFFile,
          ),
        );
      },
    );
  }

  void _preparePreviewEMLFile({
    required AppLocalizations appLocalizations,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
    required Id? blobId,
  }) {
    showDialogLoading(appLocalizations);

    if (session == null) {
      emitFailure(
        controller: this,
        failure: ParseEmailByBlobIdFailure(NotFoundSessionException()),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: ParseEmailByBlobIdFailure(NotFoundAccountIdException()),
      );
      return;
    }

    if (blobId == null) {
      emitFailure(
        controller: this,
        failure: ParseEmailByBlobIdFailure(NotFoundBlobIdException([])),
      );
      return;
    }

    consumeState(
      parseEmailByBlobIdInteractor.execute(
        accountId,
        session,
        ownEmailAddress,
        blobId,
      ),
    );
  }

  void _preparePreviewHtmlFile({
    required AppLocalizations appLocalizations,
    required Session? session,
    required AccountId? accountId,
    required Attachment attachment,
    bool isDialogLoadingVisible = false,
    DownloadSourceView? sourceView,
  }) {
    if (isDialogLoadingVisible) {
      showDialogLoading(appLocalizations);
    }

    final downloadUrl = session?.getSafetyDownloadUrl(
      jmapUrl: dynamicUrlInterceptors.jmapUrl,
    );
    final blobId = attachment.blobId;

    if (session == null) {
      emitFailure(
        controller: this,
        failure: DownloadAndGetHtmlContentFromAttachmentFailure(
          exception: NotFoundSessionException(),
          blobId: blobId,
          sourceView: sourceView,
        ),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: DownloadAndGetHtmlContentFromAttachmentFailure(
          exception: NotFoundAccountIdException(),
          blobId: blobId,
          sourceView: sourceView,
        ),
      );
      return;
    }

    if (blobId == null) {
      emitFailure(
        controller: this,
        failure: DownloadAndGetHtmlContentFromAttachmentFailure(
          exception: NotFoundBlobIdException([]),
          blobId: blobId,
          sourceView: sourceView,
        ),
      );
      return;
    }

    if (downloadUrl == null) {
      emitFailure(
        controller: this,
        failure: DownloadAndGetHtmlContentFromAttachmentFailure(
          exception: DownloadUrlIsNullException(),
          blobId: blobId,
          sourceView: sourceView,
        ),
      );
      return;
    }

    consumeState(
      downloadAndGetHtmlContentFromAttachmentInteractor.execute(
        accountId,
        session,
        attachment,
        DownloadTaskId(blobId.value),
        downloadUrl,
        TransformConfiguration.create(
          customDomTransformers: [SanitizeHyperLinkTagInHtmlTransformer()],
          customTextTransformers: [
            const StandardizeHtmlSanitizingTransformers()
          ],
        ),
        sourceView: sourceView,
      ),
    );
  }

  void _preparePreviewHtmlFileByUploadFile({
    required AppLocalizations appLocalizations,
    required UploadFileState uploadFile,
    required AccountId? accountId,
    required Session? session,
    bool isDialogLoadingVisible = false,
  }) {
    if (isDialogLoadingVisible) {
      showDialogLoading(appLocalizations);
    }
    consumeState(
      getHtmlContentFromUploadFileInteractor.execute(
        uploadFile: uploadFile,
        accountId: accountId,
        session: session,
      ),
    );
  }

  void handleParseEmailByBlobIdSuccess({
    required BuildContext? context,
    required AccountId accountId,
    required Session session,
    required String ownEmailAddress,
    required Id blobId,
    required Email email,
  }) {
    if (context == null) {
      emitFailure(
        controller: this,
        failure: PreviewEmailFromEmlFileFailure(NotFoundContextException()),
      );
      return;
    }

    final downloadUrl = session.getDownloadUrl(
      jmapUrl: dynamicUrlInterceptors.jmapUrl,
    );

    if (downloadUrl.isEmpty) {
      emitFailure(
        controller: this,
        failure: PreviewEmailFromEmlFileFailure(DownloadUrlIsNullException()),
      );
      return;
    }

    consumeState(
      previewEmailFromEmlFileInteractor.execute(
        PreviewEmailEMLRequest(
          accountId: accountId,
          session: session,
          ownEmailAddress: ownEmailAddress,
          blobId: blobId,
          email: email,
          locale: Localizations.localeOf(context),
          appLocalizations: AppLocalizations.of(context),
          baseDownloadUrl: downloadUrl,
        ),
      ),
    );
  }

  void handleParseEmailByBlobIdFailure(ParseEmailByBlobIdFailure failure) {
    closeDialogLoading();
    toastManager.showMessageFailure(failure);
  }

  void handlePreviewEmailFromEMLFileFailure(
    PreviewEmailFromEmlFileFailure failure,
  ) {
    closeDialogLoading();
    toastManager.showMessageFailure(failure);
  }

  void handleGetHtmlContentFromUploadFileSuccess(
    GetHtmlContentFromUploadFileSuccess success,
  ) {
    closeDialogLoading();

    previewHtmlFile(
      attachment: success.attachment,
      title: success.htmlAttachmentTitle,
      content: success.sanitizedHtmlContent,
      openMailToLink: (uri) async {
        if (uri == null) return;
        pushDownloadUIAction(OpenComposerFromMailtoLinkAction(uri));
      },
      onDownloadAction: (attachment) => downloadAttachment(
        attachment: attachment,
        accountId: success.accountId,
        session: success.session,
      ),
    );
  }

  void handleDownloadAndGetHtmlContentFromAttachmentSuccess(
    DownloadAndGetHtmlContentFromAttachmentSuccess success,
  ) {
    if (success.sourceView == DownloadSourceView.emailView) {
      pushDownloadUIAction(
        UpdateAttachmentsViewStateAction(
          success.attachment.blobId,
          Right<Failure, Success>(success),
        ),
      );
    }

    closeDialogLoading();

    previewHtmlFile(
      attachment: success.attachment,
      title: success.htmlAttachmentTitle,
      content: success.sanitizedHtmlContent,
      openMailToLink: (uri) async {
        if (uri == null) return;
        pushDownloadUIAction(OpenComposerFromMailtoLinkAction(uri));
      },
      onDownloadAction: (attachment) => downloadAttachment(
        attachment: attachment,
        accountId: success.accountId,
        session: success.session,
      ),
    );
  }

  void handlePreviewEmailFromEmlFileSuccess(
    PreviewEmailFromEmlFileSuccess success,
  ) {
    previewEMLFile(
      emlPreviewer: success.emlPreviewer,
      context: currentContext,
      onMailtoAction: (uri) async {
        if (uri == null) return;
        pushDownloadUIAction(OpenComposerFromMailtoLinkAction(uri));
      },
      onDownloadAction: (uri) async => downloadAttachmentInEMLPreview(
          uri: uri,
          onDownloadAction: (attachment) => downloadAttachment(
                attachment: attachment,
                accountId: success.accountId,
                session: success.session,
              )),
      onPreviewAction: (uri) async => openEMLPreviewer(
        accountId: success.accountId,
        session: success.session,
        ownEmailAddress: success.ownEmailAddress,
        uri: uri,
        appLocalizations: success.appLocalizations,
      ),
    );
  }

  void previewEMLFile({
    required EMLPreviewer emlPreviewer,
    required BuildContext? context,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentDelegateAction onDownloadAction,
    required OnPreviewEMLDelegateAction onPreviewAction,
  }) {
    closeDialogLoading();

    if (PlatformInfo.isWeb) {
      bool isOpen = HtmlUtils.openNewWindowByUrl(
        RouteUtils.createUrlWebLocationBar(
          AppRoutes.emailEMLPreviewer,
          previewId: emlPreviewer.id,
        ).toString(),
      );

      if (!isOpen) {
        toastManager.showMessageFailure(
          PreviewEmailFromEmlFileFailure(CannotOpenNewWindowException()),
        );
      }
    } else if (PlatformInfo.isMobile) {
      if (context == null) {
        toastManager.showMessageFailure(
          PreviewEmailFromEmlFileFailure(NotFoundContextException()),
        );
        return;
      }

      if (PlatformInfo.isAndroid) {
        showModalSheetToPreviewEMLAttachment(
          context: context,
          emlPreviewer: emlPreviewer,
          onMailtoAction: onMailtoAction,
          onDownloadAction: onDownloadAction,
          onPreviewAction: onPreviewAction,
        );
      } else if (PlatformInfo.isIOS) {
        showDialogToPreviewEMLAttachment(
          context: context,
          emlPreviewer: emlPreviewer,
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

  void handlePreviewHtmlFileFailure({required Failure failureState}) {
    if (failureState is DownloadAndGetHtmlContentFromAttachmentFailure &&
        failureState.sourceView == DownloadSourceView.emailView) {
      pushDownloadUIAction(
        UpdateAttachmentsViewStateAction(
          failureState.blobId,
          Left<Failure, Success>(failureState),
        ),
      );
    }

    closeDialogLoading();

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!)
            .thisHtmlAttachmentCannotBePreviewed,
      );
    }
  }

  void previewImageFile({
    required String fileName,
    required Uint8List imageBytes,
    required BuildContext? context,
    required OnDownloadWebFileAction onDownloadWebFileAction,
  }) {
    log('$runtimeType::previewImageFile: Attachment fileName is $fileName');
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
              title: fileName,
              onClose: () => Navigator.maybePop(context),
              onDownload: () => onDownloadWebFileAction(fileName, imageBytes),
            ),
          ),
        ),
        barrierDismissible: false,
      ),
    );
  }

  void previewPlainTextFile({
    required String fileName,
    required Uint8List fileBytes,
    required BuildContext? context,
    required OnDownloadWebFileAction onDownloadWebFileAction,
  }) {
    log('$runtimeType::previewPlainTextFile: Attachment fileName is $fileName');
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
              title: fileName,
              onClose: () => Navigator.maybePop(context),
              onDownload: () => onDownloadWebFileAction(fileName, fileBytes),
            ),
          ),
        ),
        barrierDismissible: false,
      ),
    );
  }

  void previewHtmlFile({
    required Attachment attachment,
    required String title,
    required String content,
    required OnMailtoDelegateAction openMailToLink,
    required OnDownloadAttachmentFileAction onDownloadAction,
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
    required AppLocalizations appLocalizations,
    required Uri? uri,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
  }) async {
    if (uri == null) return;

    final blobId = uri.path;
    if (blobId.isEmpty) return;

    _preparePreviewEMLFile(
      appLocalizations: appLocalizations,
      accountId: accountId,
      session: session,
      ownEmailAddress: ownEmailAddress,
      blobId: Id(blobId),
    );
  }

  void showDialogLoading(AppLocalizations appLocalizations) {
    SmartDialog.showLoading(
      msg: appLocalizations.loadingPleaseWait,
      maskColor: Colors.black38,
    );
  }

  void closeDialogLoading() {
    if (SmartDialog.checkExist()) {
      SmartDialog.dismiss();
    }
  }

  void showPreviewNotAvailableToastMessage(BuildContext context) {
    appToast.showToastErrorMessage(
      context,
      AppLocalizations.of(context).noPreviewAvailable,
    );
  }
}
