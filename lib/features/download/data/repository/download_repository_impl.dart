import 'dart:async';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/data/datasource/download_datasource.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';

class DownloadRepositoryImpl extends DownloadRepository {
  final DownloadDatasource _downloadDatasource;
  final Map<DataSourceType, EmailDataSource> _emailDataSource;
  final HtmlDataSource _htmlDataSource;

  DownloadRepositoryImpl(
    this._downloadDatasource,
    this._emailDataSource,
    this._htmlDataSource,
  );

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
    return _downloadDatasource.downloadAttachmentForWeb(
      taskId,
      attachment,
      accountId,
      baseDownloadUrl,
      accountRequest,
      onReceiveController: onReceiveController,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<void> downloadAllAttachmentsForWeb(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest,
    DownloadTaskId taskId, {
    StreamController<Either<Failure, Success>>? onReceiveController,
    CancelToken? cancelToken,
  }) {
    return _downloadDatasource.downloadAllAttachmentsForWeb(
      accountId,
      emailId,
      baseDownloadAllUrl,
      outputFileName,
      accountRequest,
      taskId,
      onReceiveController: onReceiveController,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<String> sanitizeHtmlContent(
    String htmlContent,
    TransformConfiguration configuration,
  ) {
    return _htmlDataSource.transformHtmlEmailContent(
      htmlContent,
      configuration,
    );
  }

  @override
  Future<List<Email>> parseEmailByBlobIds(
    AccountId accountId,
    Set<Id> blobIds,
  ) {
    return _emailDataSource[DataSourceType.network]!
        .parseEmailByBlobIds(accountId, blobIds);
  }

  @override
  Future<String> generatePreviewEmailEMLContent(
    PreviewEmailEMLRequest previewEmailEMLRequest,
  ) {
    return _emailDataSource[DataSourceType.network]!
        .generatePreviewEmailEMLContent(previewEmailEMLRequest);
  }

  @override
  Future<void> storePreviewEMLContentToSessionStorage(
    EMLPreviewer emlPreviewer,
  ) {
    return _emailDataSource[DataSourceType.session]!
        .storePreviewEMLContentToSessionStorage(emlPreviewer);
  }

  @override
  Future<void> sharePreviewEmailEMLContent(EMLPreviewer emlPreviewer) {
    return _emailDataSource[DataSourceType.local]!
        .sharePreviewEmailEMLContent(emlPreviewer);
  }

  @override
  Future<EMLPreviewer> getPreviewEmailEMLContentShared(String keyStored) {
    return _emailDataSource[DataSourceType.local]!
        .getPreviewEmailEMLContentShared(keyStored);
  }

  @override
  Future<void> removePreviewEmailEMLContentShared(String keyStored) {
    return _emailDataSource[DataSourceType.local]!
        .removePreviewEmailEMLContentShared(keyStored);
  }

  @override
  Future<EMLPreviewer> getPreviewEMLContentInMemory(String keyStored) {
    return _emailDataSource[DataSourceType.session]!
        .getPreviewEMLContentInMemory(keyStored);
  }

  @override
  Future<DownloadedResponse> exportAttachment(
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    CancelToken cancelToken,
  ) {
    return _emailDataSource[DataSourceType.network]!.exportAttachment(
      attachment,
      accountId,
      baseDownloadUrl,
      accountRequest,
      cancelToken,
    );
  }

  @override
  Future<DownloadedResponse> exportAllAttachments(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest,
    CancelToken cancelToken,
  ) {
    return _emailDataSource[DataSourceType.network]!.exportAllAttachments(
      accountId,
      emailId,
      baseDownloadAllUrl,
      outputFileName,
      accountRequest,
      cancelToken: cancelToken,
    );
  }
}
