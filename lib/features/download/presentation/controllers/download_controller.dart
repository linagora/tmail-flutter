
import 'dart:async';

import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/print_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/download/download_task_id.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_and_get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_all_attachments_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/get_html_content_from_upload_file_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_and_get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/get_html_content_from_upload_file_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/download_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/preview_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef UpdateDownloadTaskStateCallback = DownloadTaskState Function(DownloadTaskState currentState);

class DownloadController extends BaseController {
  final DownloadManager downloadManager;
  final PrintUtils printUtils;
  final DownloadAttachmentForWebInteractor downloadAttachmentForWebInteractor;
  final DownloadAllAttachmentsForWebInteractor
      downloadAllAttachmentsForWebInteractor;
  final ParseEmailByBlobIdInteractor parseEmailByBlobIdInteractor;
  final PreviewEmailFromEmlFileInteractor previewEmailFromEmlFileInteractor;
  final DownloadAndGetHtmlContentFromAttachmentInteractor
      downloadAndGetHtmlContentFromAttachmentInteractor;
  final GetHtmlContentFromUploadFileInteractor
      getHtmlContentFromUploadFileInteractor;
  final ExportAttachmentInteractor exportAttachmentInteractor;
  final ExportAllAttachmentsInteractor exportAllAttachmentsInteractor;

  DownloadController(
    this.downloadManager,
    this.printUtils,
    this.downloadAttachmentForWebInteractor,
    this.downloadAllAttachmentsForWebInteractor,
    this.parseEmailByBlobIdInteractor,
    this.previewEmailFromEmlFileInteractor,
    this.downloadAndGetHtmlContentFromAttachmentInteractor,
    this.getHtmlContentFromUploadFileInteractor,
    this.exportAttachmentInteractor,
    this.exportAllAttachmentsInteractor,
  );

  final listDownloadTaskState = RxList<DownloadTaskState>();
  final hideDownloadTaskbar = RxBool(false);
  final downloadUIAction = Rxn<DownloadUIAction>();

  final downloadProgressStateController =
      StreamController<Either<Failure, Success>>.broadcast();
  StreamSubscription<Either<Failure, Success>>?
      _downloadProgressStateSubscription;

  @override
  void onInit() {
    super.onInit();
    _registerDownloadProgressState();
  }

  void _registerDownloadProgressState() {
    _downloadProgressStateSubscription = downloadProgressStateController.stream
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

  void pushDownloadUIAction(DownloadUIAction action) {
    downloadUIAction.value = action;
  }

  void clearDownloadUIAction() {
    downloadUIAction.value = null;
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is DownloadAttachmentForWebSuccess) {
      handleDownloadAttachmentForWebSuccess(success);
    } else if (success is StartDownloadAttachmentForWeb &&
        success.sourceView == DownloadSourceView.emailView) {
      pushDownloadUIAction(UpdateAttachmentsViewStateAction(
        success.attachment.blobId,
        Right<Failure, Success>(success),
      ));
    } else if (success is DownloadingAttachmentForWeb &&
        success.sourceView == DownloadSourceView.emailView) {
      pushDownloadUIAction(UpdateAttachmentsViewStateAction(
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
      );
    } else if (success is PreviewEmailFromEmlFileSuccess) {
      handlePreviewEmailFromEmlFileSuccess(success);
    } else if (success is DownloadAndGetHtmlContentFromAttachmentSuccess) {
     handleDownloadAndGetHtmlContentFromAttachmentSuccess(success);
    } else if (success is DownloadAndGettingHtmlContentFromAttachment &&
        success.sourceView == DownloadSourceView.emailView) {
      pushDownloadUIAction(
        UpdateAttachmentsViewStateAction(
          success.blobId,
          Right<Failure, Success>(success),
        ),
      );
    } else if (success is ExportAttachmentSuccess) {
      exportAttachmentSuccessAction(success.downloadedResponse);
    } else if (success is ExportAllAttachmentsSuccess) {
      exportAllAttachmentsSuccessAction(success.downloadedResponse.filePath);
    } else if (success is GetHtmlContentFromUploadFileSuccess) {
      handleGetHtmlContentFromUploadFileSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is DownloadAllAttachmentsForWebFailure) {
      downloadAllAttachmentsForWebFailure(failureState: failure);
    } else if (failure is DownloadAttachmentForWebFailure) {
      downloadAttachmentForWebFailureAction(failureState: failure);
    } else if (failure is ParseEmailByBlobIdFailure) {
      handleParseEmailByBlobIdFailure(failure);
    } else if (failure is PreviewEmailFromEmlFileFailure) {
      handlePreviewEmailFromEMLFileFailure(failure);
    } else if (failure is GetHtmlContentFromUploadFileFailure ||
        failure is DownloadAndGetHtmlContentFromAttachmentFailure) {
      handlePreviewHtmlFileFailure(failureState: failure);
    } else if (failure is ExportAttachmentFailure) {
      exportAttachmentFailureAction(failure);
    } else if (failure is ExportAllAttachmentsFailure) {
      exportAllAttachmentsFailureAction(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void onClose() {
    _downloadProgressStateSubscription?.cancel();
    _downloadProgressStateSubscription = null;
    downloadProgressStateController.close();
    super.onClose();
  }
}