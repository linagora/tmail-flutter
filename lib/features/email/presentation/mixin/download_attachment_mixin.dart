import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/eml_attachment.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/mixin/emit_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

mixin DownloadAttachmentMixin on EmitMixin {
  final DynamicUrlInterceptors _dynamicUrlInterceptors =
      Get.find<DynamicUrlInterceptors>();
  final Uuid _uuid = Get.find<Uuid>();
  final AppToast _appToast = Get.find<AppToast>();
  final DownloadManager _downloadManager = Get.find<DownloadManager>();

  void exportAttachment({
    required Attachment attachment,
    required BaseController controller,
    required AccountId? accountId,
    required Session? session,
    required ExportAttachmentInteractor exportAttachmentInteractor,
  }) {
    final cancelToken = CancelToken();

    showDownloadingFileDialog(
      attachmentName: attachment.name ?? '',
      cancelToken: cancelToken,
    );

    _exportAttachmentAction(
      attachment: attachment,
      cancelToken: cancelToken,
      controller: controller,
      accountId: accountId,
      session: session,
      exportAttachmentInteractor: exportAttachmentInteractor,
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

  void _exportAttachmentAction({
    required Attachment attachment,
    required CancelToken cancelToken,
    required BaseController controller,
    required AccountId? accountId,
    required Session? session,
    required ExportAttachmentInteractor exportAttachmentInteractor,
  }) {
    if (session == null) {
      emitFailure(
        controller: controller,
        failure: ExportAttachmentFailure(NotFoundSessionException()),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: controller,
        failure: ExportAttachmentFailure(NotFoundAccountIdException()),
      );
      return;
    }

    try {
      final baseDownloadUrl = session.getDownloadUrl(
        jmapUrl: _dynamicUrlInterceptors.jmapUrl,
      );

      controller.consumeState(
        exportAttachmentInteractor.execute(
          attachment,
          accountId,
          baseDownloadUrl,
          cancelToken,
        ),
      );
    } catch (e) {
      emitFailure(
        controller: controller,
        failure: ExportAttachmentFailure(e),
      );
    }
  }

  void downloadAttachmentForWeb({
    required Attachment attachment,
    required BaseController controller,
    required AccountId? accountId,
    required Session? session,
    required DownloadAttachmentForWebInteractor downloadInteractor,
    bool previewerSupported = false,
    StreamController<Either<Failure, Success>>? onReceiveController,
  }) {
    if (session == null) {
      emitFailure(
        controller: controller,
        failure: DownloadAttachmentForWebFailure(
          attachment: attachment,
          exception: NotFoundSessionException(),
        ),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: controller,
        failure: DownloadAttachmentForWebFailure(
          attachment: attachment,
          exception: NotFoundAccountIdException(),
        ),
      );
      return;
    }

    final generateTaskId = DownloadTaskId(_uuid.v4());
    try {
      final baseDownloadUrl = session.getDownloadUrl(
        jmapUrl: _dynamicUrlInterceptors.jmapUrl,
      );
      final cancelToken = CancelToken();
      controller.consumeState(downloadInteractor.execute(
        generateTaskId,
        attachment,
        accountId,
        baseDownloadUrl,
        onReceiveController: onReceiveController,
        cancelToken: cancelToken,
        previewerSupported: previewerSupported,
      ));
    } catch (e) {
      emitFailure(
        controller: controller,
        failure: DownloadAttachmentForWebFailure(
          attachment: attachment,
          taskId: generateTaskId,
          exception: e,
        ),
      );
    }
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
        _appToast.showToastWarningMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).user_cancel_download_file,
        );
      }
      return;
    }

    popBack();
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachment_download_failed,
      );
    }
  }

  void exportAttachmentFailureAction(dynamic exception) {
    if (exception is CancelDownloadFileException) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastWarningMessage(
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
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachment_download_failed,
      );
    }
  }

  void downloadAttachmentForWebFailureAction({
    required DownloadAttachmentForWebFailure failureState,
    VoidCallback? onCallbackAction,
  }) {
    onCallbackAction?.call();

    if (currentOverlayContext == null || currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);
    String message = appLocalizations.attachment_download_failed;
    if (failureState.attachment is EMLAttachment) {
      message = appLocalizations.downloadMessageAsEMLFailed;
    } else if (failureState.cancelToken?.isCancelled == true) {
      message = appLocalizations.downloadAttachmentHasBeenCancelled;
    }

    _appToast.showToastErrorMessage(currentOverlayContext!, message);
  }

  void downloadAllAttachmentsForWebFailure({
    required DownloadAllAttachmentsForWebFailure failureState,
    VoidCallback? onCallbackAction,
  }) {
    onCallbackAction?.call();

    if (currentOverlayContext == null || currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);
    final message = failureState.cancelToken?.isCancelled == true
        ? appLocalizations.downloadAttachmentHasBeenCancelled
        : appLocalizations.attachment_download_failed;

    _appToast.showToastErrorMessage(currentOverlayContext!, message);
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

  void downloadAttachmentInEMLPreview({
    required OnDownloadAttachmentFileAction onDownloadAction,
    required Uri? uri,
  }) {
    if (uri == null) return;

    final attachment = EmailUtils.parsingAttachmentByUri(uri);
    if (attachment == null) return;

    onDownloadAction(attachment);
  }
}
