
import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/attachment_extension.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/list_file_info_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/extensions/upload_attachment_extension.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state_list.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class UploadController extends BaseController {

  final _mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final UploadAttachmentInteractor _uploadAttachmentInteractor;

  final listUploadAttachments = <UploadFileState>[].obs;
  final uploadInlineViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  final StreamGroup<Either<Failure, Success>> _progressUploadStateStreamGroup
    = StreamGroup<Either<Failure, Success>>.broadcast();
  final StreamGroup<Either<Failure, Success>> _progressUploadInlineImageStateStreamGroup
    = StreamGroup<Either<Failure, Success>>.broadcast();

  StreamSubscription? _uploadAttachmentStreamSubscription;
  StreamSubscription? _uploadInlineImageStreamSubscription;

  final UploadFileStateList _uploadingStateFiles = UploadFileStateList();
  final UploadFileStateList _uploadingStateInlineFiles = UploadFileStateList();

  UploadController(this._uploadAttachmentInteractor);

  @override
  void onInit() {
    _registerProgressUploadStateStream();
    super.onInit();
  }

  @override
  void onClose() {
    listUploadAttachments.clear();
    _uploadingStateFiles.clear();
    _uploadingStateInlineFiles.clear();
    uploadInlineViewState.value = Right(UIClosedState());
    dispatchState(Right(UIClosedState()));
    _progressUploadStateStreamGroup.close();
    _progressUploadInlineImageStateStreamGroup.close();
    _uploadAttachmentStreamSubscription?.cancel();
    _uploadInlineImageStreamSubscription?.cancel();
    super.onClose();
  }

  void _registerProgressUploadStateStream() {
    _uploadAttachmentStreamSubscription = _progressUploadStateStreamGroup.stream.listen(_handleProgressUploadStateStream);
    _uploadInlineImageStreamSubscription = _progressUploadInlineImageStateStreamGroup.stream.listen(_handleProgressUploadInlineImageStateStream);
  }

  void _handleProgressUploadStateStream(Either<Failure, Success> uploadState) {
    uploadState.fold(
      (failure) {
          log('UploadController::_handleProgressUploadStateStream():failure: $failure');
          if (failure is ErrorAttachmentUploadState) {
            _uploadingStateFiles.updateElementByUploadTaskId(
                failure.uploadId,
                (currentState) => currentState?.copyWith(uploadStatus: UploadFileStatus.uploadFailed));
            deleteFileUploaded(failure.uploadId);
            _showToastMessageWhenUploadAttachmentsFailure(failure);
            consumeState(Stream.value((Left(failure))));
          }
        },
      (success) {
          if (success is UploadingAttachmentUploadState) {
            log('UploadController::_registerUploadAttachmentsState():uploading[${success.uploadId}]: ${success.progress}');
            _uploadingStateFiles.updateElementByUploadTaskId(
                success.uploadId,
                (currentState) {
                  if (currentState?.uploadStatus.completed ?? false) {
                    return currentState;
                  } else {
                    return currentState?.copyWith(
                        uploadingProgress: (success.progress * 100 / success.total).floor(),
                        uploadStatus: UploadFileStatus.uploading);
                  }
                }
            );

            _refreshListUploadAttachmentState();
          } else if (success is SuccessAttachmentUploadState) {
            log('UploadController::_handleProgressUploadStateStream():succeed[${success.uploadId}]');
            _uploadingStateFiles.updateElementByUploadTaskId(
              success.uploadId,
              (currentState) {
                final newState = currentState?.copyWith(
                    uploadingProgress: 100,
                    uploadStatus: UploadFileStatus.succeed,
                    attachment: success.attachment
                );
                return newState;
              },
            );

            _refreshListUploadAttachmentState();
            _showToastMessageWhenUploadAttachmentsSuccess(success);
          }
        }
    );
  }

  void _handleProgressUploadInlineImageStateStream(Either<Failure, Success> uploadState) {
    uploadState.fold(
      (failure) {
        log('UploadController::_handleProgressUploadInlineImageStateStream():failure: $failure');
        if (failure is ErrorAttachmentUploadState) {
          uploadInlineViewState.value = Left(failure);
          _deleteInlineFileUploaded(failure.uploadId);

          if (currentContext != null && currentOverlayContext != null) {
            appToast.showToastErrorMessage(
              currentOverlayContext!,
              AppLocalizations.of(currentContext!).thisImageCannotBeAdded,
              leadingSVGIconColor: Colors.white,
              leadingSVGIcon: imagePaths.icInsertImage);
          }
          consumeState(Stream.value((Left(failure))));
        }
      },
      (success) {
        if (success is UploadingAttachmentUploadState) {
          log('UploadController::_handleProgressUploadInlineImageStateStream():uploading[${success.uploadId}]: ${success.progress}');
          _uploadingStateInlineFiles.updateElementByUploadTaskId(
              success.uploadId,
              (currentState) {
                if (currentState?.uploadStatus.completed ?? false) {
                  return currentState;
                } else {
                  return currentState?.copyWith(
                      uploadingProgress: (success.progress * 100 / success.total).floor(),
                      uploadStatus: UploadFileStatus.uploading);
                }
              }
          );
          uploadInlineViewState.value = Right(success);
        } else if (success is SuccessAttachmentUploadState) {
          log('UploadController::_handleProgressUploadInlineImageStateStream():succeed[${success.uploadId}]');
          final inlineAttachment = success.attachment.toAttachmentWithDisposition(
            disposition: ContentDisposition.inline,
            cid: uuid.v1()
          );

          _uploadingStateInlineFiles.updateElementByUploadTaskId(
            success.uploadId,
            (currentState) {
              final newState = currentState?.copyWith(
                  uploadingProgress: 100,
                  uploadStatus: UploadFileStatus.succeed,
                  attachment: inlineAttachment
              );
              return newState;
            },
          );
          final newUploadSuccess = SuccessAttachmentUploadState(
            success.uploadId,
            inlineAttachment,
            success.fileInfo,
          );
          _handleUploadInlineAttachmentsSuccess(newUploadSuccess);
        }
      }
    );
  }

  void initializeUploadAttachments(List<Attachment> attachments) {
    _uploadingStateFiles.addAll(
      attachments.map((attachment) => UploadFileState(
        UploadTaskId(attachment.blobId!.value),
        uploadStatus: UploadFileStatus.succeed,
        attachment: attachment
      ))
    );
    _refreshListUploadAttachmentState();
  }

  void initializeUploadInlineAttachments(List<Attachment> inlineAttachments) {
    _uploadingStateInlineFiles.addAll(
      inlineAttachments.map((inlineAttachment) => UploadFileState(
        UploadTaskId(inlineAttachment.blobId!.value),
        uploadStatus: UploadFileStatus.succeed,
        attachment: inlineAttachment,
      ))
    );
    _refreshListUploadAttachmentState();
  }

  void deleteFileUploaded(UploadTaskId uploadId) {
    _uploadingStateFiles.deleteElementByUploadTaskId(uploadId);
    _refreshListUploadAttachmentState();
  }

  Future<void> justUploadAttachmentsAction({
    required List<FileInfo> uploadFiles,
    required Uri uploadUri,
  }) {
    return Future.forEach<FileInfo>(uploadFiles, (uploadFile) async {
      await uploadFileAction(uploadFile: uploadFile, uploadUri: uploadUri);
    });
  }

  Future<void> uploadFileAction({
    required FileInfo uploadFile,
    required Uri uploadUri,
  }) {
    log('UploadController::_uploadFile():fileName: ${uploadFile.fileName} | mimeType: ${uploadFile.mimeType} | isInline: ${uploadFile.isInline} | fromFileShared: ${uploadFile.isShared}');
    consumeState(_uploadAttachmentInteractor.execute(
      uploadFile,
      uploadUri,
      cancelToken: CancelToken(),
    ));
    return Future.value();
  }

  void _refreshListUploadAttachmentState() {
    listUploadAttachments.value =
        _uploadingStateFiles.uploadingStateFiles.whereNotNull().toList();
    listUploadAttachments.refresh();
  }

  List<Attachment> get attachmentsUploaded {
    if (listUploadAttachments.isEmpty) {
      return List.empty();
    }
    return listUploadAttachments
        .map((fileState) => fileState.attachment)
        .whereNotNull()
        .toList();
  }

  List<FileInfo> get attachmentsPicked {
    if (listUploadAttachments.isEmpty) {
      return List.empty();
    }
    return listUploadAttachments
      .map((fileState) => fileState.file)
      .whereNotNull()
      .toList();
  }

  Set<EmailBodyPart>? generateAttachments() {
    if (attachmentsUploaded.isEmpty) {
      return null;
    }
    return attachmentsUploaded
      .map((attachment) => attachment.toEmailBodyPart())
      .toSet();
  }

  void _showToastMessageWhenUploadAttachmentsFailure(ErrorAttachmentUploadState failure) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icAttachment);
    }
  }

  void _showToastMessageWhenUploadAttachmentsSuccess(SuccessAttachmentUploadState success) {
    if (currentContext != null && currentOverlayContext != null && _uploadingStateFiles.allSuccess) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachments_uploaded_successfully,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icAttachment);
    }
  }

  bool isExceededMaxSizeAttachmentsPerEmail({num totalSizePreparedFiles = 0}) {
    final currentTotalSize = attachmentsPicked.totalSize + inlineAttachmentsPicked.totalSize + totalSizePreparedFiles;
    final maxSizeAttachmentsPerEmail = _mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value;
    log('UploadController::isExceededMaxSizeAttachmentsPerEmail(): currentTotalSize = $currentTotalSize | maxSizeAttachmentsPerEmail = $maxSizeAttachmentsPerEmail');
    if (maxSizeAttachmentsPerEmail != null) {
      return currentTotalSize > maxSizeAttachmentsPerEmail;
    } else {
      return false;
    }
  }

  bool isExceededWarningAttachmentFileSizeInComposer({num totalSizePreparedFiles = 0}) {
    final currentTotalSizeAttachments = attachmentsPicked.totalSize + totalSizePreparedFiles;
    const maximumBytesSizeFileAttachedInComposer = AppConfig.warningAttachmentFileSizeInMegabytes * 1024 * 1024;
    log('UploadController::isExceededMaxSizeFilesAttachedInComposer(): currentTotalSizeAttachments = $currentTotalSizeAttachments | maximumBytesSizeFileAttachedInComposer = $maximumBytesSizeFileAttachedInComposer');
    return currentTotalSizeAttachments > maximumBytesSizeFileAttachedInComposer;
  }

  void validateTotalSizeAttachmentsBeforeUpload({
    required num totalSizePreparedFiles,
    num? totalSizePreparedFilesWithDispositionAttachment,
    VoidCallback? onValidationSuccess
  }) {
    log('UploadController::_validateTotalSizeAttachmentsBeforeUpload: totalSizePreparedFiles = $totalSizePreparedFiles');
    if (isExceededMaxSizeAttachmentsPerEmail(totalSizePreparedFiles: totalSizePreparedFiles)) {
      if (currentContext == null) {
        log('UploadController::_validateTotalSizeAttachmentsBeforeUpload: CONTEXT IS NULL');
        return;
      }

      _showConfirmDialogWhenExceededMaxSizeAttachmentsPerEmail(context: currentContext!);
      return;
    }

    if (isExceededWarningAttachmentFileSizeInComposer(totalSizePreparedFiles: totalSizePreparedFilesWithDispositionAttachment ?? totalSizePreparedFiles)) {
      if (currentContext == null) {
        log('UploadController::_validateTotalSizeAttachmentsBeforeUpload: CONTEXT IS NULL');
        return;
      }

      _showWarningDialogWhenExceededMaxSizeFilesAttachedInComposer(
        context: currentContext!,
        confirmAction: () async {
          await Future.delayed(
            const Duration(milliseconds: 100),
            onValidationSuccess
          );
        }
      );
      return;
    }

    onValidationSuccess?.call();
  }

  void validateTotalSizeInlineAttachmentsBeforeUpload({
    required num totalSizePreparedFiles,
    VoidCallback? onValidationSuccess
  }) {
    if (isExceededMaxSizeAttachmentsPerEmail(totalSizePreparedFiles: totalSizePreparedFiles)) {
      if (currentContext == null) {
        log('UploadController::validateTotalSizeInlineAttachmentsBeforeUpload: CONTEXT IS NULL');
        return;
      }

      _showConfirmDialogWhenExceededMaxSizeAttachmentsPerEmail(context: currentContext!);
      return;
    }

    onValidationSuccess?.call();
  }

  void _showConfirmDialogWhenExceededMaxSizeAttachmentsPerEmail({required BuildContext context}) {
    final maxSizeAttachmentsPerEmail = filesize(_mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0);
    showConfirmDialogAction(
      context,
      AppLocalizations.of(context).message_dialog_upload_attachments_exceeds_maximum_size(maxSizeAttachmentsPerEmail),
      AppLocalizations.of(context).got_it,
      title: AppLocalizations.of(context).maximum_files_size,
      hasCancelButton: false);
  }

  void _showWarningDialogWhenExceededMaxSizeFilesAttachedInComposer({
    required BuildContext context,
    VoidCallback? confirmAction,
  }) {
    showConfirmDialogAction(
      context,
      title: '',
      AppLocalizations.of(context).warningMessageWhenExceedGenerallySizeInComposer,
      AppLocalizations.of(context).cancel,
      cancelTitle: AppLocalizations.of(context).continueAction,
      alignCenter: true,
      onCancelAction: confirmAction,
    );
  }

  bool get allUploadAttachmentsCompleted {
    return listUploadAttachments
        .every((uploadFile) => uploadFile.uploadStatus.completed);
  }

  void _deleteInlineFileUploaded(UploadTaskId uploadId) {
    _uploadingStateInlineFiles.deleteElementByUploadTaskId(uploadId);
  }

  void _handleUploadInlineAttachmentsSuccess(SuccessAttachmentUploadState success) {
    uploadInlineViewState.value = Right(success);
  }

  void clearUploadInlineViewState() {
    uploadInlineViewState.value = Right(UIState.idle);
  }

  List<Attachment> get inlineAttachmentsUploaded {
    if (_uploadingStateInlineFiles.uploadingStateFiles.isEmpty) {
      return [];
    }
    return _uploadingStateInlineFiles.uploadingStateFiles.fold<List<Attachment>>(
      [],
      (list, fileState) {
        final attachment = fileState?.attachment;
        if (attachment?.cid != null) {
          list.add(attachment!);
        }
        return list;
      },
    );
  }

  List<FileInfo> get inlineAttachmentsPicked {
    if (_uploadingStateInlineFiles.uploadingStateFiles.isEmpty) {
      return [];
    }
    return _uploadingStateInlineFiles.uploadingStateFiles.fold<List<FileInfo>>(
      [],
      (list, fileState) {
        final file = fileState?.file;
        if (file != null) {
          list.add(file);
        }
        return list;
      },
    );
  }

  Map<String, Attachment> get mapInlineAttachments {
    if (_uploadingStateInlineFiles.uploadingStateFiles.isEmpty) {
      return {};
    }
    final mapInlineAttachments = _uploadingStateInlineFiles.uploadingStateFiles.fold<Map<String, Attachment>>(
      {},
      (map, fileState) {
        final attachment = fileState?.attachment;
        if (attachment?.cid != null) {
          map[attachment!.cid!] = attachment;
        }
        return map;
      },
    );

    log('UploadController::mapInlineAttachments(): Found ${mapInlineAttachments.length} inline attachments.');

    return mapInlineAttachments;
  }

  List<Attachment> get allAttachmentsUploaded => [
    ...attachmentsUploaded,
    ...inlineAttachmentsUploaded,
  ];

  void _handleUploadAttachmentFailure(UploadAttachmentFailure failure) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        failure.fileInfo.isInline == true
          ? AppLocalizations.of(currentContext!).thisImageCannotBeAdded
          : AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: failure.fileInfo.isInline == true
          ? imagePaths.icInsertImage
          : imagePaths.icAttachment
      );
    }
  }

  void _handleUploadAttachmentSuccess(UploadAttachmentSuccess success) async {
    if (success.uploadAttachment.fileInfo.isInline == true) {
      _uploadingStateInlineFiles.add(success.uploadAttachment.toUploadFileState());
      await _progressUploadInlineImageStateStreamGroup.add(success.uploadAttachment.progressState);
    } else {
      _uploadingStateFiles.add(success.uploadAttachment.toUploadFileState());
      await _progressUploadStateStreamGroup.add(success.uploadAttachment.progressState);
      _refreshListUploadAttachmentState();
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is UploadAttachmentFailure) {
      _handleUploadAttachmentFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) async {
    if (success is UploadAttachmentSuccess) {
      _handleUploadAttachmentSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }
}