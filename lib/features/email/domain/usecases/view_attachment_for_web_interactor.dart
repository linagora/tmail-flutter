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
          .execute(
            taskId,
            attachment,
            accountId,
            baseDownloadUrl,
            onReceiveController)
          .map(
            (result) => result.fold(
              (failure) {
                if (failure is DownloadAttachmentForWebFailure) {
                  return Left(ViewAttachmentForWebFailure(
                    attachment: attachment,
                    taskId: failure.taskId,
                    exception: failure.exception,
                  ));
                }

                return Left(failure);
              },
              (success) {
                if (success is StartDownloadAttachmentForWeb) {
                  return Right(StartViewAttachmentForWeb(
                    success.taskId,
                    success.attachment,
                  ));
                }

                if (success is DownloadingAttachmentForWeb) {
                  return Right(ViewingAttachmentForWeb(
                    success.taskId,
                    success.attachment,
                    success.progress,
                    success.downloaded,
                    success.total,
                  ));
                }

                if (success is DownloadAttachmentForWebSuccess) {
                  return Right(ViewAttachmentForWebSuccess(
                    success.taskId,
                    success.attachment,
                    success.bytes,
                  ));
                }

                return Right(success);
              },
            ),
          );
}
