import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_text_data_from_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';

class GetTextDataFromAttachmentInteractor {
  const GetTextDataFromAttachmentInteractor(this._downloadAttachmentForWebInteractor);

  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;

  Stream<Either<Failure, Success>> execute(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    {CancelToken? cancelToken,}
  ) async* {
    final onProgressStream = StreamController<Either<Failure, Success>>();
    try {
      yield Right(GettingTextDataFromAttachment(attachment: attachment));
      final downloadState = await _downloadAttachmentForWebInteractor.execute(
        taskId,
        attachment,
        accountId,
        baseDownloadUrl,
        onProgressStream,
        cancelToken: cancelToken,
      ).last;

      yield downloadState.fold(
        (failure) {
          return Left(GetTextDataFromAttachmentFailure(
            exception: failure is FeatureFailure ? failure.exception : null,
          ));
        },
        (success) {
          if (success is! DownloadAttachmentForWebSuccess) {
            return Left(GetTextDataFromAttachmentFailure());
          }

          return Right(GetTextDataFromAttachmentSuccess(
            attachment: attachment,
            data: success.bytes,
          ));
        },
      );
    } catch (e) {
      logError('GetTextDataFromAttachmentInteractor::execute(): $e');
      yield Left(GetTextDataFromAttachmentFailure(exception: e));
    }
    onProgressStream.close();
  }
}