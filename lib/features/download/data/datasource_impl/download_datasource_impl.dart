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
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/download/data/datasource/download_datasource.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class DownloadDatasourceImpl extends DownloadDatasource {
  final EmailAPI _emailAPI;
  final ExceptionThrower _exceptionThrower;

  DownloadDatasourceImpl(this._emailAPI, this._exceptionThrower);

  @override
  Future<Uint8List> downloadAttachmentForWeb(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest, {
    StreamController<Either<Failure, Success>>? onReceiveController,
    CancelToken? cancelToken,
  }) {
    return Future.sync(() async {
      return await _emailAPI.downloadAttachmentForWeb(
        taskId,
        attachment,
        accountId,
        baseDownloadUrl,
        accountRequest,
        onReceiveController: onReceiveController,
        cancelToken: cancelToken,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> downloadAllAttachmentsForWeb(
      AccountId accountId,
      EmailId emailId,
      String baseDownloadAllUrl,
      String outputFileName,
      AccountRequest accountRequest,
      DownloadTaskId taskId,
      {StreamController<Either<Failure, Success>>? onReceiveController,
      CancelToken? cancelToken}) {
    return Future.sync(() async {
      return await _emailAPI.downloadAllAttachmentsForWeb(
        accountId,
        emailId,
        baseDownloadAllUrl,
        outputFileName,
        accountRequest,
        taskId,
        onReceiveController: onReceiveController,
        cancelToken: cancelToken,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}
