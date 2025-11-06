import 'dart:async';
import 'dart:typed_data';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';

abstract class DownloadRepository {
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

  Future<String> sanitizeHtmlContent(
    String htmlContent,
    TransformConfiguration configuration,
  );

  Future<List<Email>> parseEmailByBlobIds(AccountId accountId, Set<Id> blobIds);

  Future<String> generatePreviewEmailEMLContent(
    PreviewEmailEMLRequest previewEmailEMLRequest,
  );

  Future<void> sharePreviewEmailEMLContent(EMLPreviewer emlPreviewer);

  Future<void> storePreviewEMLContentToSessionStorage(
    EMLPreviewer emlPreviewer,
  );

  Future<EMLPreviewer> getPreviewEmailEMLContentShared(String keyStored);

  Future<void> removePreviewEmailEMLContentShared(String keyStored);

  Future<EMLPreviewer> getPreviewEMLContentInMemory(String keyStored);

  Future<DownloadedResponse> exportAttachment(
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    CancelToken cancelToken,
  );

  Future<DownloadedResponse> exportAllAttachments(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest,
    CancelToken cancelToken,
  );
}
