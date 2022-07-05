
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/attachment_extension.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state_list.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class UploadController extends GetxController {

  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();
  final _mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final UploadAttachmentInteractor _uploadAttachmentInteractor;

  final listUploadAttachments = <UploadFileState>[].obs;

  final StreamGroup<Either<Failure, Success>> _progressUploadStateStreamGroup
    = StreamGroup<Either<Failure, Success>>.broadcast();

  final UploadFileStateList _uploadingStateFiles = UploadFileStateList();

  UploadController(this._uploadAttachmentInteractor);

  @override
  void onInit() {
    _registerProgressUploadStateStream();
    super.onInit();
  }

  @override
  void onClose() {
    _uploadingStateFiles.clear();
    _progressUploadStateStreamGroup.close();
    super.onClose();
  }

  void _registerProgressUploadStateStream() {
    _progressUploadStateStreamGroup.stream.listen(_handleProgressUploadStateStream);
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
            _handleUploadAttachmentsFailure(failure);
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
            _handleUploadAttachmentsSuccess(success);
          }
        }
    );
  }

  void initializeUploadAttachments(List<Attachment> attachments) {
    listUploadAttachments.value = attachments
        .map((attachment) => UploadFileState(UploadTaskId(attachment.blobId!.value)))
        .toList();
  }

  void deleteFileUploaded(UploadTaskId uploadId) {
    _uploadingStateFiles.deleteElementByUploadTaskId(uploadId);
    _refreshListUploadAttachmentState();
  }

  Future<void> justUploadAttachmentsAction(List<FileInfo> uploadFiles, Uri uploadUri) async {
    return Future.forEach<FileInfo>(uploadFiles, (uploadFile) async {
      await _uploadFile(uploadFile, uploadUri);
    });
  }

  Future<void> _uploadFile(FileInfo uploadFile, Uri uploadUri) async {
    log('UploadAttachmentManager::_uploadFile(): ${uploadFile.fileName}');

    final cancelToken = CancelToken();
    final uploadAttachment = _uploadAttachmentInteractor.execute(
        uploadFile, uploadUri,
        cancelToken: cancelToken);

    _uploadingStateFiles.add(UploadFileState(
        uploadAttachment.uploadTaskId,
        file: uploadFile,
        cancelToken: cancelToken));

    await _progressUploadStateStreamGroup.add(uploadAttachment.progressState);

    _refreshListUploadAttachmentState();
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

  Set<EmailBodyPart>? generateAttachments() {
    if (attachmentsUploaded.isEmpty) {
      return null;
    }
    return attachmentsUploaded
        .map((attachment) => attachment.toEmailBodyPart(ContentDisposition.attachment.value))
        .toSet();
  }

  void _handleUploadAttachmentsFailure(ErrorAttachmentUploadState failure) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithIcon(currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments,
          textColor: AppColor.toastErrorBackgroundColor,
          iconColor: AppColor.toastErrorBackgroundColor,
          icon: _imagePaths.icAttachment);
    }
  }

  void _handleUploadAttachmentsSuccess(SuccessAttachmentUploadState success) {
    if (currentContext != null && currentOverlayContext != null && _uploadingStateFiles.allSuccess) {
      _appToast.showToastWithIcon(currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).attachments_uploaded_successfully,
          iconColor: AppColor.primaryColor,
          icon: _imagePaths.icAttachment);
    }
  }

  bool hasEnoughMaxAttachmentSize({List<FileInfo>? listFiles}) {
    final currentTotalAttachmentsSize = attachmentsUploaded.totalSize();
    log('ComposerController::_validateAttachmentsSize(): $currentTotalAttachmentsSize');
    num uploadedTotalSize = 0;
    if (listFiles != null && listFiles.isNotEmpty) {
      final uploadedListSize = listFiles.map((file) => file.fileSize).toList();
      uploadedTotalSize = uploadedListSize.reduce((sum, size) => sum + size);
      log('ComposerController::_validateAttachmentsSize(): uploadedTotalSize: $uploadedTotalSize');
    }

    final totalSizeReadyToUpload = currentTotalAttachmentsSize + uploadedTotalSize;
    log('ComposerController::_validateAttachmentsSize(): totalSizeReadyToUpload: $totalSizeReadyToUpload');

    final maxSizeAttachmentsPerEmail = _mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value;
    if (maxSizeAttachmentsPerEmail != null) {
      return totalSizeReadyToUpload <= maxSizeAttachmentsPerEmail;
    } else {
      return false;
    }
  }

  bool get allUploadAttachmentsCompleted {
    return listUploadAttachments
        .every((uploadFile) => uploadFile.uploadStatus.completed);
  }
}