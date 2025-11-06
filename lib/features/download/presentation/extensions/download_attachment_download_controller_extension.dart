import 'dart:async';
import 'dart:io';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/domain/exceptions/download_file_exception.dart';
import 'package:core/presentation/extensions/media_type_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/dialog/downloading_file_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/eml_attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/download/domain/exceptions/download_attachment_exceptions.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_all_attachments_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/preview_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnDownloadWebFileAction = void Function(String name, Uint8List bytes);

extension DownloadAttachmentDownloadControllerExtension on DownloadController {
  void downloadAttachment({
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
    bool previewerSupported = false,
    bool showBottomDownloadProgressBar = false,
    DownloadSourceView? sourceView,
  }) {
    if (PlatformInfo.isWeb) {
      downloadAttachmentForWeb(
        attachment: attachment,
        accountId: accountId,
        session: session,
        previewerSupported: previewerSupported,
        onReceiveController: showBottomDownloadProgressBar
            ? downloadProgressStateController
            : null,
        sourceView: sourceView,
      );
    } else if (PlatformInfo.isMobile) {
      exportAttachment(
        attachment: attachment,
        accountId: accountId,
        session: session,
      );
    } else {
      log('$runtimeType::downloadAttachment: THE PLATFORM IS SUPPORTED');
    }
  }

  Future<void> downloadAllAttachments({
    required String outputFileName,
    required EmailId? emailId,
    required AccountId? accountId,
    required Session? session,
    bool showBottomDownloadProgressBar = false,
  }) async {
    if (PlatformInfo.isWeb) {
      downloadAllAttachmentsForWeb(
        outputFileName: outputFileName,
        emailId: emailId,
        session: session,
        accountId: accountId,
        onReceiveController: showBottomDownloadProgressBar
            ? downloadProgressStateController
            : null,
      );
    } else if (PlatformInfo.isMobile) {
      exportAllAttachments(
        outputFileName: outputFileName,
        emailId: emailId,
        session: session,
        accountId: accountId,
      );
    } else {
      log('$runtimeType::downloadAllAttachments: THE PLATFORM IS SUPPORTED');
    }
  }

  void exportAttachment({
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
  }) {
    final cancelToken = CancelToken();

    showDownloadingFileDialog(
      attachmentName: attachment.name ?? '',
      cancelToken: cancelToken,
    );

    if (session == null) {
      emitFailure(
        controller: this,
        failure: ExportAttachmentFailure(NotFoundSessionException()),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: ExportAttachmentFailure(NotFoundAccountIdException()),
      );
      return;
    }

    final baseDownloadUrl = session.getSafetyDownloadUrl(
      jmapUrl: dynamicUrlInterceptors.jmapUrl,
    );

    consumeState(
      exportAttachmentInteractor.execute(
        attachment,
        accountId,
        baseDownloadUrl,
        cancelToken,
      ),
    );
  }

  void showDownloadingFileDialog({
    required String attachmentName,
    required CancelToken cancelToken,
  }) {
    Get.dialog(
      PointerInterceptor(
        child: Builder(
          builder: (context) {
            final appLocalizations = AppLocalizations.of(context);
            return (DownloadingFileDialogBuilder()
                  ..key(const Key('downloading_file_dialog'))
                  ..title(appLocalizations.preparing_to_export)
                  ..content(appLocalizations.downloading_file(attachmentName))
                  ..actionText(appLocalizations.cancel)
                  ..addCancelDownloadActionClick(() {
                    cancelToken.cancel([
                      appLocalizations.user_cancel_download_file,
                    ]);
                    popBack();
                  }))
                .build();
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  void downloadAttachmentForWeb({
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
    bool previewerSupported = false,
    StreamController<Either<Failure, Success>>? onReceiveController,
    DownloadSourceView? sourceView,
  }) {
    if (session == null) {
      emitFailure(
        controller: this,
        failure: DownloadAttachmentForWebFailure(
          attachment: attachment,
          exception: NotFoundSessionException(),
          sourceView: sourceView,
        ),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: DownloadAttachmentForWebFailure(
          attachment: attachment,
          exception: NotFoundAccountIdException(),
          sourceView: sourceView,
        ),
      );
      return;
    }

    final generateTaskId = DownloadTaskId(uuid.v4());
    final baseDownloadUrl = session.getSafetyDownloadUrl(
      jmapUrl: dynamicUrlInterceptors.jmapUrl,
    );
    final cancelToken = CancelToken();

    consumeState(downloadAttachmentForWebInteractor.execute(
      generateTaskId,
      attachment,
      accountId,
      baseDownloadUrl,
      onReceiveController: onReceiveController,
      cancelToken: cancelToken,
      previewerSupported: previewerSupported,
      sourceView: sourceView,
    ));
  }

  void exportAttachmentSuccessAction(DownloadedResponse downloadedResponse) {
    popBack();
    _openDownloadedPreviewWorkGroupDocument(
      filePath: downloadedResponse.filePath,
      mediaType: downloadedResponse.mediaType,
    );
  }

  Future<void> _openDownloadedPreviewWorkGroupDocument({
    required String filePath,
    MediaType? mediaType,
  }) async {
    if (mediaType == null) {
      await _saveFileToStorage(filePath);
      return;
    }

    final openResult = await open_file.OpenFile.open(
      filePath,
      type: Platform.isAndroid ? mediaType.mimeType : null,
      // "xdg" is default value
      linuxDesktopName:
          Platform.isIOS ? mediaType.getDocumentUti().value ?? 'xdg' : 'xdg',
    );

    if (openResult.type != open_file.ResultType.done) {
      await _saveFileToStorage(filePath);
    }
  }

  Future<void> _saveFileToStorage(String filePath) async {
    final params = SaveFileDialogParams(sourceFilePath: filePath);
    await FlutterFileDialog.saveFile(params: params);
  }

  void exportAllAttachmentsSuccessAction(String filePath) {
    popBack();
    _saveFileToStorage(filePath);
  }

  void exportAllAttachmentsFailureAction(dynamic exception) {
    if (exception is CancelDownloadFileException) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastWarningMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).user_cancel_download_file,
        );
      }
      return;
    }

    popBack();
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachment_download_failed,
      );
    }
  }

  void exportAttachmentFailureAction(dynamic exception) {
    if (exception is CancelDownloadFileException) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastWarningMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).user_cancel_download_file,
        );
      }
      return;
    }

    if (Get.isDialogOpen == true) {
      popBack();
    }

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachment_download_failed,
      );
    }
  }

  void downloadAttachmentForWebFailureAction({
    required DownloadAttachmentForWebFailure failureState,
  }) {
    closeDialogLoading();

    if (failureState.taskId != null) {
      deleteDownloadTask(failureState.taskId!);
    }

    if (failureState.attachment != null &&
        failureState.sourceView == DownloadSourceView.emailView) {
      pushDownloadUIAction(
        UpdateAttachmentsViewStateAction(
          failureState.attachment?.blobId,
          Left<Failure, Success>(failureState),
        ),
      );
    }

    if (currentOverlayContext == null || currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);
    String message = appLocalizations.attachment_download_failed;
    if (failureState.attachment is EMLAttachment) {
      message = appLocalizations.downloadMessageAsEMLFailed;
    } else if (failureState.cancelToken?.isCancelled == true) {
      message = appLocalizations.downloadAttachmentHasBeenCancelled;
    }

    appToast.showToastErrorMessage(currentOverlayContext!, message);
  }

  void downloadAllAttachmentsForWebFailure({
    required DownloadAllAttachmentsForWebFailure failureState,
  }) {
    deleteDownloadTask(failureState.taskId);

    if (currentOverlayContext == null || currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);
    final message = failureState.cancelToken?.isCancelled == true
        ? appLocalizations.downloadAttachmentHasBeenCancelled
        : appLocalizations.attachment_download_failed;

    appToast.showToastErrorMessage(currentOverlayContext!, message);
  }

  void downloadFileWeb({
    required String fileName,
    required Uint8List fileBytes,
  }) {
    downloadManager.createAnchorElementDownloadFileWeb(
      fileBytes,
      fileName,
    );
  }

  void downloadAttachmentInEMLPreview({
    required OnDownloadAttachmentFileAction onDownloadAction,
    required Uri? uri,
  }) {
    if (uri == null) return;

    final attachment = EmailUtils.parsingAttachmentByUri(uri);
    if (attachment == null) return;

    onDownloadAction(attachment);
  }

  void exportAllAttachments({
    required String outputFileName,
    required EmailId? emailId,
    required AccountId? accountId,
    required Session? session,
  }) {
    final cancelToken = CancelToken();

    showDownloadingFileDialog(
      attachmentName: outputFileName,
      cancelToken: cancelToken,
    );

    if (session == null) {
      emitFailure(
        controller: this,
        failure: ExportAllAttachmentsFailure(
          exception: NotFoundSessionException(),
        ),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: ExportAllAttachmentsFailure(
          exception: NotFoundAccountIdException(),
        ),
      );
      return;
    }

    if (emailId == null) {
      emitFailure(
        controller: this,
        failure: ExportAllAttachmentsFailure(
          exception: NotFoundEmailException(),
        ),
      );
      return;
    }

    final downloadAllSupported = session.isDownloadAllSupported(accountId);
    if (!downloadAllSupported) {
      emitFailure(
        controller: this,
        failure: ExportAllAttachmentsFailure(
          exception: CapabilityDownloadAllNotSupportedException(),
        ),
      );
      return;
    }

    final baseDownloadAllUrl =
        session.getDownloadAllCapability(accountId)!.endpoint!;

    consumeState(
      exportAllAttachmentsInteractor.execute(
        accountId,
        emailId,
        baseDownloadAllUrl,
        outputFileName,
        cancelToken,
      ),
    );
  }

  void downloadAllAttachmentsForWeb({
    required String outputFileName,
    required EmailId? emailId,
    required AccountId? accountId,
    required Session? session,
    bool previewerSupported = false,
    StreamController<Either<Failure, Success>>? onReceiveController,
  }) {
    final taskId = DownloadTaskId(uuid.v4());

    if (session == null) {
      emitFailure(
        controller: this,
        failure: DownloadAllAttachmentsForWebFailure(
          exception: NotFoundSessionException(),
          taskId: taskId,
        ),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: DownloadAllAttachmentsForWebFailure(
          exception: NotFoundAccountIdException(),
          taskId: taskId,
        ),
      );
      return;
    }

    if (emailId == null) {
      emitFailure(
        controller: this,
        failure: DownloadAllAttachmentsForWebFailure(
          exception: NotFoundEmailException(),
          taskId: taskId,
        ),
      );
      return;
    }

    final downloadAllSupported = session.isDownloadAllSupported(accountId);

    if (!downloadAllSupported) {
      emitFailure(
        controller: this,
        failure: DownloadAllAttachmentsForWebFailure(
          exception: CapabilityDownloadAllNotSupportedException(),
          taskId: taskId,
        ),
      );
      return;
    }

    final baseDownloadAllUrl =
        session.getDownloadAllCapability(accountId)!.endpoint!;

    final downloadAttachment = Attachment(
      name: outputFileName,
      type: MediaType('application', 'zip'),
    );

    final cancelToken = CancelToken();

    consumeState(
      downloadAllAttachmentsForWebInteractor.execute(
        accountId,
        emailId,
        baseDownloadAllUrl,
        downloadAttachment,
        taskId,
        onReceiveController: onReceiveController,
        cancelToken: cancelToken,
      ),
    );
  }

  void downloadMessageAsEML({
    required PresentationEmail presentationEmail,
    required AccountId? accountId,
    required Session? session,
    bool showBottomDownloadProgressBar = false,
  }) {
    if (session == null) {
      emitFailure(
        controller: this,
        failure: DownloadAttachmentForWebFailure(
          exception: NotFoundSessionException(),
        ),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: DownloadAttachmentForWebFailure(
          exception: NotFoundAccountIdException(),
        ),
      );
      return;
    }

    final emlAttachment = presentationEmail.createEMLAttachment();
    if (emlAttachment.blobId == null) {
      emitFailure(
        controller: this,
        failure: DownloadAttachmentForWebFailure(
          exception: NotFoundEmailBlobIdException(),
        ),
      );
      return;
    }

    final generateTaskId = DownloadTaskId(uuid.v4());
    final baseDownloadUrl = session.getSafetyDownloadUrl(
      jmapUrl: dynamicUrlInterceptors.jmapUrl,
    );
    final cancelToken = CancelToken();

    consumeState(
      downloadAttachmentForWebInteractor.execute(
        generateTaskId,
        emlAttachment,
        accountId,
        baseDownloadUrl,
        onReceiveController: showBottomDownloadProgressBar
            ? downloadProgressStateController
            : null,
        cancelToken: cancelToken,
        previewerSupported: false,
      ),
    );
  }

  void handleDownloadAttachmentForWebSuccess(
    DownloadAttachmentForWebSuccess success,
  ) {
    closeDialogLoading();

    if (success.sourceView == DownloadSourceView.emailView) {
      pushDownloadUIAction(UpdateAttachmentsViewStateAction(
        success.attachment.blobId,
        Right<Failure, Success>(success),
      ));
    }

    deleteDownloadTask(success.taskId);

    if (!success.previewerSupported) {
      downloadFileWeb(
        fileBytes: success.bytes,
        fileName: success.attachment.generateFileName(),
      );
      return;
    }

    if (success.attachment.isImage) {
      previewImageFile(
        fileName: success.attachment.generateFileName(),
        imageBytes: success.bytes,
        context: currentContext,
        onDownloadWebFileAction: (name, bytes) => downloadFileWeb(
          fileName: name,
          fileBytes: bytes,
        ),
      );
    } else if (success.attachment.isText || success.attachment.isJson) {
      previewPlainTextFile(
        fileName: success.attachment.generateFileName(),
        fileBytes: success.bytes,
        context: currentContext,
        onDownloadWebFileAction: (name, bytes) => downloadFileWeb(
          fileName: name,
          fileBytes: bytes,
        ),
      );
    }
  }
}
