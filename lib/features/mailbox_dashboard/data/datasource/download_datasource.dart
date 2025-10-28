import 'dart:async';
import 'dart:typed_data';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';

abstract class DownloadDatasource {
  Future<Uint8List> downloadAttachmentForWeb(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest, {
    StreamController<Either<Failure, Success>>? onReceiveController,
    CancelToken? cancelToken,
  });

  Future<void> downloadAllAttachmentsForWeb(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest,
    DownloadTaskId taskId, {
    StreamController<Either<Failure, Success>>? onReceiveController,
    CancelToken? cancelToken,
  });
}
