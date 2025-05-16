import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleCollapsedEmailDownloadStates on ThreadDetailController {
  void handleDownloadProgressState(Either<Failure, Success> state) {
    state.fold(
      (failure) => null,
      (success) {
        if (success is StartDownloadAttachmentForWeb &&
            !success.previewerSupported
        ) {
          mailboxDashBoardController.addDownloadTask(
            DownloadTaskState(
              taskId: success.taskId,
              attachment: success.attachment,
              onCancel: () => success.cancelToken?.cancel(),
            ),
          );

          if (currentOverlayContext != null &&
              currentContext != null &&
              !success.previewerSupported
          ) {
            appToast.showToastMessage(
              currentOverlayContext!,
              AppLocalizations.of(currentContext!).your_download_has_started,
              leadingSVGIconColor: AppColor.primaryColor,
              leadingSVGIcon: imagePaths.icDownload,
            );
          }
        } else if (success is DownloadingAttachmentForWeb) {
          mailboxDashBoardController.updateDownloadTask(
            success.taskId,
            (currentTask) {
              final newTask = currentTask.copyWith(
                progress: success.progress,
                downloaded: success.downloaded,
                total: success.total,
              );

              return newTask;
            },
          );
        }
      }
    );
  }

  void handleDownloadSuccess(DownloadAttachmentForWebSuccess success) {
    mailboxDashBoardController.deleteDownloadTask(success.taskId);

    downloadManager.createAnchorElementDownloadFileWeb(
      success.bytes,
      success.attachment.generateFileName());
  }

  void handleDownloadFailure(DownloadAttachmentForWebFailure failure) {
    if (failure.taskId != null) {
      mailboxDashBoardController.deleteDownloadTask(failure.taskId!);
    }

    if (currentOverlayContext == null || currentContext == null) return;

    final message = AppLocalizations.of(currentContext!).downloadMessageAsEMLFailed;
    appToast.showToastErrorMessage(currentOverlayContext!, message);
  }
}