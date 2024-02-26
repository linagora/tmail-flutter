import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/view_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';

class ViewAttachmentForWebInteractor {
  ViewAttachmentForWebInteractor(this._downloadAttachmentForWebInteractor);

  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;

  Stream<Either<Failure, Success>> execute(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    StreamController<Either<Failure, Success>> onReceiveController,
  ) =>
      _downloadAttachmentForWebInteractor
          .execute(taskId, attachment, accountId, baseDownloadUrl,
              onReceiveController)
          .map(
            (result) => result.fold(
              (failure) {
                if (failure is DownloadAttachmentForWebFailure) {
                  return left(ViewAttachmentForWebFailure(
                      taskId: failure.taskId, exception: failure.exception));
                }

                return left(failure);
              },
              (r) {
                if (r is StartDownloadAttachmentForWeb) {
                  return right(
                      StartViewAttachmentForWeb(r.taskId, r.attachment));
                }

                if (r is DownloadingAttachmentForWeb) {
                  return right(ViewingAttachmentForWeb(r.taskId, r.attachment,
                      r.progress, r.downloaded, r.total));
                }

                if (r is DownloadAttachmentForWebSuccess) {
                  return right(ViewAttachmentForWebSuccess(
                      r.taskId, r.attachment, r.bytes));
                }

                return right(r);
              },
            ),
          );
}
