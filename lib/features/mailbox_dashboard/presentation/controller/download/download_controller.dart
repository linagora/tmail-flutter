
import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/eml_attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/mixin/preview_attachment_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/html_attachment_previewer.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:twake_previewer_flutter/core/constants/supported_charset.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/previewer_state.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/top_bar_options.dart';
import 'package:twake_previewer_flutter/core/previewer_options/previewer_options.dart';
import 'package:twake_previewer_flutter/twake_image_previewer/twake_image_previewer.dart';
import 'package:twake_previewer_flutter/twake_plain_text_previewer/twake_plain_text_previewer.dart';
import 'package:uuid/uuid.dart';

typedef UpdateDownloadTaskStateCallback = DownloadTaskState Function(DownloadTaskState currentState);

class DownloadController extends BaseController with PreviewAttachmentMixin {
  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;
  final DownloadAllAttachmentsForWebInteractor
      _downloadAllAttachmentsForWebInteractor;
  final DownloadManager _downloadManager;
  final ParseEmailByBlobIdInteractor parseEmailByBlobIdInteractor;
  final PreviewEmailFromEmlFileInteractor previewEmailFromEmlFileInteractor;
  final GetHtmlContentFromAttachmentInteractor
      getHtmlContentFromAttachmentInteractor;

  DownloadController(
    this._downloadAttachmentForWebInteractor,
    this._downloadAllAttachmentsForWebInteractor,
    this._downloadManager,
    this.parseEmailByBlobIdInteractor,
    this.previewEmailFromEmlFileInteractor,
    this.getHtmlContentFromAttachmentInteractor,
  );

  final listDownloadTaskState = RxList<DownloadTaskState>();
  final hideDownloadTaskbar = RxBool(false);
  final downloadUIAction = Rxn<DownloadUIAction>();

  final _downloadProgressStateController =
      StreamController<Either<Failure, Success>>.broadcast();
  StreamSubscription<Either<Failure, Success>>?
      _downloadProgressStateSubscription;

  @override
  void onInit() {
    super.onInit();
    _registerDownloadProgressState();
  }

  void _registerDownloadProgressState() {
    _downloadProgressStateSubscription = _downloadProgressStateController.stream
        .listen(_onDownloadProgressStateChanged);
  }

  void _onDownloadProgressStateChanged(Either<Failure, Success> state) {
    state.fold((_) => null, (success) {
      if (success is StartDownloadAttachmentForWeb) {
        _handleStartSingleDownload(success);
      } else if (success is DownloadingAttachmentForWeb) {
        _updateDownloadProgress(
          success.taskId,
          success.progress,
          success.downloaded,
          success.total,
        );
      } else if (success is StartDownloadAllAttachmentsForWeb) {
        _handleStartAllDownload(success);
      } else if (success is DownloadingAllAttachmentsForWeb) {
        _updateDownloadProgress(
          success.taskId,
          success.progress,
          success.downloaded,
          success.total,
        );
      }
    });
  }

  void _handleStartSingleDownload(StartDownloadAttachmentForWeb success) {
    if (success.previewerSupported) return;

    addDownloadTask(
      DownloadTaskState(
        taskId: success.taskId,
        attachment: success.attachment,
        onCancel: success.cancelToken?.cancel,
      ),
    );

    if (_hasValidContext) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).your_download_has_started,
        leadingSVGIconColor: AppColor.primaryColor,
        leadingSVGIcon: imagePaths.icDownload,
      );
    }
  }

  void _handleStartAllDownload(StartDownloadAllAttachmentsForWeb success) {
    addDownloadTask(
      DownloadTaskState(
        taskId: success.taskId,
        attachment: success.attachment,
        onCancel: () => success.cancelToken?.cancel(),
      ),
    );

    if (_hasValidContext) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).creatingAnArchiveForDownloading,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icDownloadAll,
      );
    }
  }

  void _updateDownloadProgress(
    DownloadTaskId taskId,
    double progress,
    int downloaded,
    int total,
  ) {
    final percent = progress.round();
    log('$runtimeType::_updateDownloadProgress(): $percent%');

    updateDownloadTaskByTaskId(taskId, (currentTask) {
      return currentTask.copyWith(
        progress: progress,
        downloaded: downloaded,
        total: total,
      );
    });
  }

  bool get _hasValidContext =>
      currentOverlayContext != null && currentContext != null;

  bool get notEmptyListDownloadTask => listDownloadTaskState.isNotEmpty;

  void addDownloadTask(DownloadTaskState task) {
    log('DownloadController::addDownloadTask(): ${task.taskId}');
    listDownloadTaskState.add(task);
    hideDownloadTaskbar.value = false;
  }

  void updateDownloadTaskByTaskId(
      DownloadTaskId downloadTaskId,
      UpdateDownloadTaskStateCallback updateDownloadTaskCallback,
  ) {
    final matchIndex = listDownloadTaskState
        .indexWhere((task) => task.taskId == downloadTaskId);
    if (matchIndex >= 0) {
      listDownloadTaskState[matchIndex] = updateDownloadTaskCallback(listDownloadTaskState[matchIndex]);
      listDownloadTaskState.refresh();
    }
  }

  void deleteDownloadTask(DownloadTaskId taskId) {
    log('DownloadController::deleteDownloadTask(): $taskId');
    final matchIndex = listDownloadTaskState
        .indexWhere((task) => task.taskId == taskId);
    if (matchIndex >= 0) {
      listDownloadTaskState.removeAt(matchIndex);
      listDownloadTaskState.refresh();
    }
    if (listDownloadTaskState.isEmpty) {
      hideDownloadTaskbar.value = true;
    }
  }

  void downloadAttachmentForWeb({
    required Attachment attachment,
    required AccountId? accountId,
    required Session? session,
    bool previewerSupported = false,
  }) {
    if (accountId == null || session == null) {
      consumeState(Stream.value(
        Left(DownloadAttachmentForWebFailure(
          attachment: attachment,
          exception: NotFoundSessionException(),
        )),
      ));
      return;
    }

    final generateTaskId = DownloadTaskId(uuid.v4());
    try {
      final baseDownloadUrl = session.getDownloadUrl(
        jmapUrl: dynamicUrlInterceptors.jmapUrl,
      );
      final cancelToken = CancelToken();
      consumeState(_downloadAttachmentForWebInteractor.execute(
        generateTaskId,
        attachment,
        accountId,
        baseDownloadUrl,
        onReceiveController: _downloadProgressStateController,
        cancelToken: cancelToken,
        previewerSupported: previewerSupported,
      ));
    } catch (e) {
      consumeState(Stream.value(
        Left(DownloadAttachmentForWebFailure(
          attachment: attachment,
          taskId: generateTaskId,
          exception: e,
        )),
      ));
    }
  }

  void downloadAllAttachmentsForWeb({
    required String outputFileName,
    required PresentationEmail? currentEmail,
    required AccountId? accountId,
    required Session? session,
    bool previewerSupported = false,
  }) {
    final taskId = DownloadTaskId(uuid.v4());

    if (accountId == null || session == null) {
      consumeState(Stream.value(
        Left(DownloadAllAttachmentsForWebFailure(
          exception: NotFoundSessionException(),
          taskId: taskId,
        )),
      ));
      return;
    }

    final downloadAllSupported = session.isDownloadAllSupported(accountId);
    final emailId = currentEmail?.id;

    if (!downloadAllSupported || emailId == null) {
      consumeState(Stream.value(
        Left(DownloadAllAttachmentsForWebFailure(taskId: taskId)),
      ));
      return;
    }

    final baseDownloadAllUrl = session.getDownloadAllCapability(accountId)!.endpoint!;
    final downloadAttachment = Attachment(
      name: outputFileName,
      type: MediaType('application', 'zip'),
    );
    final cancelToken = CancelToken();
    consumeState(_downloadAllAttachmentsForWebInteractor.execute(
      accountId,
      emailId,
      baseDownloadAllUrl,
      downloadAttachment,
      taskId,
      onReceiveController: _downloadProgressStateController,
      cancelToken: cancelToken,
    ));
  }

  void downloadMessageAsEML({
    required PresentationEmail presentationEmail,
    required AccountId? accountId,
    required Session? session,
  }) {
    if (accountId == null || session == null) return;

    final emlAttachment = presentationEmail.createEMLAttachment();
    if (emlAttachment.blobId == null) {
      consumeState(Stream.value(
        Left(DownloadAttachmentForWebFailure(
          exception: NotFoundEmailBlobIdException(),
        )),
      ));
      return;
    }

    final generateTaskId = DownloadTaskId(const Uuid().v4());
    try {
      final baseDownloadUrl = session.getDownloadUrl(
        jmapUrl: getBinding<DynamicUrlInterceptors>()?.jmapUrl,
      );
      final cancelToken = CancelToken();
      consumeState(_downloadAttachmentForWebInteractor.execute(
        generateTaskId,
        emlAttachment,
        accountId,
        baseDownloadUrl,
        onReceiveController: _downloadProgressStateController,
        cancelToken: cancelToken,
        previewerSupported: false,
      ));
    } catch (e) {
      consumeState(Stream.value(Left(DownloadAttachmentForWebFailure(
        attachment: emlAttachment,
        taskId: generateTaskId,
        exception: e,
      ))));
    }
  }

  void _pushDownloadUIAction(DownloadUIAction action) {
    downloadUIAction.value = action;
  }

  void _handleDownloadAttachmentForWebSuccess(
    DownloadAttachmentForWebSuccess success,
  ) {
    _pushDownloadUIAction(UpdateAttachmentsViewStateAction(
      success.attachment.blobId,
      Right<Failure, Success>(success),
    ));

    deleteDownloadTask(success.taskId);

    if (!success.previewerSupported) {
      _downloadManager.createAnchorElementDownloadFileWeb(
        success.bytes,
        success.attachment.generateFileName(),
      );
      return;
    }

    if (success.attachment.isImage) {
      _previewImageFile(attachment: success.attachment, bytes: success.bytes);
    } else if (success.attachment.isText || success.attachment.isJson) {
      _previewTextPlainFile(
        attachment: success.attachment,
        bytes: success.bytes,
      );
    }
  }

  void _downloadAttachmentQuickly(Attachment attachment) {
    if (PlatformInfo.isWeb) {
      _pushDownloadUIAction(DownloadAttachmentsQuicklyAction(attachment));
    }
  }

  void _previewImageFile({
    required Uint8List bytes,
    required Attachment attachment,
  }) {
    if (currentContext == null) return;

    Navigator.of(currentContext!).push(GetDialogRoute(
      pageBuilder: (context, _, __) => PointerInterceptor(
        child: TwakeImagePreviewer(
          bytes: bytes,
          zoomable: true,
          previewerOptions: const PreviewerOptions(
            previewerState: PreviewerState.success,
          ),
          topBarOptions: TopBarOptions(
            title: attachment.generateFileName(),
            onClose: () => Navigator.maybePop(context),
            onDownload: currentContext == null
                ? null
                : () => _downloadAttachmentQuickly(attachment),
          ),
        ),
      ),
      barrierDismissible: false,
    ));
  }

  void _previewTextPlainFile({
    required Uint8List bytes,
    required Attachment attachment,
  }) {
    if (currentContext == null) return;

    Navigator.of(currentContext!).push(GetDialogRoute(
      pageBuilder: (context, _, __) => PointerInterceptor(
        child: TwakePlainTextPreviewer(
          supportedCharset: SupportedCharset.utf8,
          bytes: bytes,
          previewerOptions: PreviewerOptions(
            previewerState: PreviewerState.success,
            width: currentContext == null ? 200 : currentContext!.width * 0.8,
          ),
          topBarOptions: TopBarOptions(
            title: attachment.generateFileName(),
            onClose: () => Navigator.maybePop(context),
            onDownload: currentContext == null
                ? null
                : () => _downloadAttachmentQuickly(attachment),
          ),
        ),
      ),
      barrierDismissible: false,
    ));
  }

  void clearDownloadUIAction() {
    downloadUIAction.value = null;
  }

  void _downloadAllAttachmentsForWebFailure(
    DownloadAllAttachmentsForWebFailure failure,
  ) {
    deleteDownloadTask(failure.taskId);

    if (currentOverlayContext == null || currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);

    String message = failure.cancelToken?.isCancelled == true
        ? appLocalizations.downloadAttachmentHasBeenCancelled
        : appLocalizations.attachment_download_failed;

    appToast.showToastErrorMessage(currentOverlayContext!, message);
  }

  void _downloadAttachmentForWebFailureAction(DownloadAttachmentForWebFailure failure) {
    if (failure.taskId != null) {
      deleteDownloadTask(failure.taskId!);
    }

    if (failure.attachment != null) {
      _pushDownloadUIAction(
        UpdateAttachmentsViewStateAction(
          failure.attachment?.blobId,
          Left<Failure, Success>(failure),
        ),
      );
    }

    if (currentOverlayContext == null || currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);

    String message = appLocalizations.attachment_download_failed;
    if (failure.attachment is EMLAttachment) {
      message = appLocalizations.downloadMessageAsEMLFailed;
    } else if (failure.cancelToken?.isCancelled == true) {
      message = appLocalizations.downloadAttachmentHasBeenCancelled;
    }

    appToast.showToastErrorMessage(currentOverlayContext!, message);
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is DownloadAttachmentForWebSuccess) {
      _handleDownloadAttachmentForWebSuccess(success);
    } else if (success is StartDownloadAttachmentForWeb) {
      _pushDownloadUIAction(UpdateAttachmentsViewStateAction(
        success.attachment.blobId,
        Right<Failure, Success>(success),
      ));
    } else if (success is DownloadingAttachmentForWeb) {
      _pushDownloadUIAction(UpdateAttachmentsViewStateAction(
        success.attachment.blobId,
        Right<Failure, Success>(success),
      ));
    } else if (success is DownloadAllAttachmentsForWebSuccess) {
      deleteDownloadTask(success.taskId);
    } else if (success is ParseEmailByBlobIdSuccess) {
      handleParseEmailByBlobIdSuccess(
        context: currentContext,
        accountId: success.accountId,
        session: success.session,
        ownEmailAddress: success.ownEmailAddress,
        blobId: success.blobId,
        email: success.email,
        controller: this,
        previewInteractor: previewEmailFromEmlFileInteractor,
      );
    } else if (success is PreviewEmailFromEmlFileSuccess) {
      handlePreviewEmailFromEMLFileSuccess(
        emlPreviewer: success.emlPreviewer,
        context: currentContext,
        imagePaths: imagePaths,
        onMailtoAction: _openMailtoLink,
        onDownloadAction: (uri) async {
          if (uri == null) return;

          final attachment = EmailUtils.parsingAttachmentByUri(uri);
          if (attachment == null) return;

          _downloadAttachmentQuickly(attachment);
        },
        onPreviewAction: (uri) async {
          if (currentContext != null && uri?.path.isNotEmpty == true) {
            previewEMLFileAction(
              appLocalizations: AppLocalizations.of(currentContext!),
              accountId: success.accountId,
              session: success.session,
              ownEmailAddress: success.ownEmailAddress,
              blobId: Id(uri!.path),
              controller: this,
              parseEmailByBlobIdInteractor: parseEmailByBlobIdInteractor,
            );
          }
        },
      );
    } else if (success is GetHtmlContentFromAttachmentSuccess) {
      _pushDownloadUIAction(
        UpdateAttachmentsViewStateAction(
          success.attachment.blobId,
          Right<Failure, Success>(success),
        ),
      );

      Get.dialog(HtmlAttachmentPreviewer(
        title: success.htmlAttachmentTitle,
        htmlContent: success.sanitizedHtmlContent,
        mailToClicked: _openMailtoLink,
        downloadAttachmentClicked: () =>
            _downloadAttachmentQuickly(success.attachment),
        responsiveUtils: responsiveUtils,
      ));
    } else if (success is GettingHtmlContentFromAttachment) {
      _pushDownloadUIAction(
        UpdateAttachmentsViewStateAction(
          success.attachment.blobId,
          Right<Failure, Success>(success),
        ),
      );
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is DownloadAllAttachmentsForWebFailure) {
      _downloadAllAttachmentsForWebFailure(failure);
    } else if (failure is DownloadAttachmentForWebFailure) {
      _downloadAttachmentForWebFailureAction(failure);
    } else if (failure is ParseEmailByBlobIdFailure) {
      handleParseEmailByBlobIdFailure(failure);
    } else if (failure is PreviewEmailFromEmlFileFailure) {
      handlePreviewEmailFromEMLFileFailure(failure);
    } else if (failure is GetHtmlContentFromAttachmentFailure) {
      _handleGetHtmlContentFromAttachmentFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  void _handleGetHtmlContentFromAttachmentFailure(
    GetHtmlContentFromAttachmentFailure failure,
  ) {
    _pushDownloadUIAction(
      UpdateAttachmentsViewStateAction(
        failure.attachment.blobId,
        Left<Failure, Success>(failure),
      ),
    );

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!)
            .thisHtmlAttachmentCannotBePreviewed,
      );
    }
  }

  Future<void> _openMailtoLink(Uri? uri) async {
    _pushDownloadUIAction(OpenMailtoLinkFromPreviewAttachmentAction(uri));
  }

  @override
  void onClose() {
    _downloadProgressStateSubscription?.cancel();
    _downloadProgressStateSubscription = null;
    _downloadProgressStateController.close();
    super.onClose();
  }
}