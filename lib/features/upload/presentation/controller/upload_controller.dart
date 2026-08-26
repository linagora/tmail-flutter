
import 'dart:async';

import 'package:async/async.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/attachment_extension.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/extensions/upload_attachment_extension.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_transfer_placeholder.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state_list.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class UploadController extends BaseController {

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
    _uploadingStateFiles.cancelAll();
    _uploadingStateInlineFiles.cancelAll();
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

  /// Shows a chip for every picked drive file up front, before any transfer starts.
  void addDownloadingPlaceholders(List<DriveTransferPlaceholder> placeholders) {
    if (placeholders.isEmpty) return;
    _uploadingStateFiles.addAll(placeholders.map((placeholder) => UploadFileState(
      placeholder.taskId,
      file: FileInfo(
        fileName: placeholder.fileName,
        fileSize: placeholder.fileSize,
        type: placeholder.mimeType,
      ),
      uploadStatus: UploadFileStatus.waiting,
      cancelToken: placeholder.cancelToken,
    )));
    _refreshListUploadAttachmentState();
  }

  /// Resolves a drive-transfer chip to succeed with its attachment.
  void resolveDriveTransferSuccess(UploadTaskId taskId, Attachment attachment) {
    _uploadingStateFiles.updateElementByUploadTaskId(
      taskId,
      (state) => state?.copyWith(
        uploadingProgress: 100,
        uploadStatus: UploadFileStatus.succeed,
        attachment: attachment,
      ),
    );
    _refreshListUploadAttachmentState();
  }

  /// Resolves a drive-transfer chip to failed by removing it, matching the
  /// plain-upload failure path.
  void resolveDriveTransferFailure(UploadTaskId taskId) {
    deleteFileUploaded(taskId);
    _showToastMessageWhenUploadAttachmentsFailure(
      ErrorAttachmentUploadState(uploadId: taskId),
    );
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
        _uploadingStateFiles.uploadingStateFiles.nonNulls.toList();
    listUploadAttachments.refresh();
  }

  List<Attachment> get attachmentsUploaded {
    if (listUploadAttachments.isEmpty) {
      return List.empty();
    }
    return listUploadAttachments
        .map((fileState) => fileState.attachment)
        .nonNulls
        .toList();
  }

  List<FileInfo> get attachmentsPicked {
    if (listUploadAttachments.isEmpty) {
      return List.empty();
    }
    return listUploadAttachments
      .map((fileState) => fileState.file)
      .nonNulls
      .toList();
  }

  /// Bytes of every regular (non-inline) attachment, whether newly picked or
  /// already attached (e.g. restored from a draft), unlike [attachmentsPicked]
  /// which only sees entries that still carry a [FileInfo].
  int get regularAttachmentsTotalBytes => listUploadAttachments
      .fold<num>(0, (total, fileState) => total + fileState.fileSize)
      .toInt();

  UploadFileState? getUploadFileId(UploadTaskId id) {
    return listUploadAttachments
        .firstWhereOrNull((fileState) => fileState.uploadTaskId == id);
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
    } else {
      // The chip is already gone, so an unshowable toast loses the reason entirely.
      logError('UploadController::_showToastMessageWhenUploadAttachmentsFailure: no context to show failure for ${failure.uploadId}');
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

  /// Bytes of every inline attachment, whether newly picked or already
  /// attached, unlike [inlineAttachmentsPicked] which only sees entries that
  /// still carry a [FileInfo].
  int get inlineAttachmentsTotalBytes => _uploadingStateInlineFiles.uploadingStateFiles
      .nonNulls
      .fold<num>(0, (total, fileState) => total + fileState.fileSize)
      .toInt();

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

  void refreshAllAttachments(
    List<Attachment> attachments,
    List<Attachment> htmlBodyAttachments,
  ) {
    final regularAttachments = attachments.getListAttachmentsDisplayedOutside(htmlBodyAttachments);
    final inlineAttachments = attachments.listAttachmentsDisplayedInContent;

    // A still-running upload has no blob yet, so the server response cannot
    // rebuild it; dropping it would strand the request and lose its chip.
    final pendingRegularStates = _pendingStatesOf(_uploadingStateFiles);
    final pendingInlineStates = _pendingStatesOf(_uploadingStateInlineFiles);

    _uploadingStateFiles.clear();
    _uploadingStateFiles.addAll(_toUploadFileStates(regularAttachments));
    _uploadingStateFiles.addAll(pendingRegularStates);

    _uploadingStateInlineFiles.clear();
    _uploadingStateInlineFiles.addAll(_toUploadFileStates(inlineAttachments));
    _uploadingStateInlineFiles.addAll(pendingInlineStates);

    _refreshListUploadAttachmentState();
    log('UploadController::refreshAllAttachments(): regular=${regularAttachments.length} | inline=${inlineAttachments.length}');
  }

  List<UploadFileState> _pendingStatesOf(UploadFileStateList stateList) =>
    stateList.uploadingStateFiles
      .nonNulls
      .where((fileState) => !fileState.uploadStatus.completed)
      .toList();

  Iterable<UploadFileState> _toUploadFileStates(List<Attachment> attachments) =>
    attachments
      .where((a) => a.blobId != null)
      .map((a) => UploadFileState(
        UploadTaskId(a.blobId!.value),
        uploadStatus: UploadFileStatus.succeed,
        attachment: a,
      ));

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