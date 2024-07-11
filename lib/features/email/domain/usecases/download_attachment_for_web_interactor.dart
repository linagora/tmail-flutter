import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';

class DownloadAttachmentForWebInteractor {
  final EmailRepository _emailRepository;
  final AccountRepository _accountRepository;

  DownloadAttachmentForWebInteractor(this._emailRepository, this._accountRepository);

  Stream<Either<Failure, Success>> execute(
      DownloadTaskId taskId,
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      StreamController<Either<Failure, Success>> onReceiveController,
      {CancelToken? cancelToken}
  ) async* {
    try {
      yield Right<Failure, Success>(StartDownloadAttachmentForWeb(taskId, attachment));
      onReceiveController.add(Right(StartDownloadAttachmentForWeb(taskId, attachment)));

      final currentAccount = await _accountRepository.getCurrentAccount();

      final bytesDownloaded = await _emailRepository.downloadAttachmentForWeb(
        taskId,
        attachment,
        accountId,
        baseDownloadUrl,
        currentAccount,
        onReceiveController,
        cancelToken: cancelToken
      );

      yield Right<Failure, Success>(
        DownloadAttachmentForWebSuccess(
          taskId,
          attachment,
          bytesDownloaded
        )
      );
    } catch (exception) {
      yield Left<Failure, Success>(
        DownloadAttachmentForWebFailure(
          attachment: attachment,
          taskId: taskId,
          exception: exception
        )
      );
    }
  }
}