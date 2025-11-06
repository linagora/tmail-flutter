import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/string_convert.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_and_get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_attachment_for_web_interactor.dart';

class DownloadAndGetHtmlContentFromAttachmentInteractor {
  DownloadAndGetHtmlContentFromAttachmentInteractor(
    this._downloadAttachmentForWebInteractor,
  );

  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Session session,
    Attachment attachment,
    DownloadTaskId taskId,
    String baseDownloadUrl,
    TransformConfiguration transformConfiguration, {
    DownloadSourceView? sourceView,
  }) async* {
    try {
      yield Right(DownloadAndGettingHtmlContentFromAttachment(
        blobId: attachment.blobId,
        sourceView: sourceView,
      ));
      final downloadState = await _downloadAttachmentForWebInteractor.execute(
        taskId,
        attachment,
        accountId,
        baseDownloadUrl,
        sourceView: sourceView,
      ).last;
      
      Either<Failure, Success>? sanitizeState;
      await downloadState.fold(
        (failure) {
          sanitizeState = Left(DownloadAndGetHtmlContentFromAttachmentFailure(
            exception: failure is FeatureFailure ? failure.exception : null,
            blobId: attachment.blobId,
            sourceView: sourceView,
          ));
        },
        (success) async {
          if (success is! DownloadAttachmentForWebSuccess) {
            sanitizeState = Right(DownloadAndGettingHtmlContentFromAttachment(
              blobId: attachment.blobId,
              sourceView: sourceView,
            ));
          } else {
            final htmlContent = StringConvert.decodeFromBytes(
              success.bytes,
              charset: success.attachment.charset,
              isHtml: true,
            );
            sanitizeState = await _sanitizeHtmlContent(
              htmlContent,
              transformConfiguration,
              attachment,
              accountId,
              session,
              sourceView,
            );
          }
        },
      );

      if (sanitizeState != null) {
        yield sanitizeState!;
      } else {
        yield Left(DownloadAndGetHtmlContentFromAttachmentFailure(
          exception: null,
          blobId: attachment.blobId,
          sourceView: sourceView,
        ));
      }
    } catch (e) {
      logError('GetHtmlContentFromAttachmentInteractor:exception: $e');
      yield Left(DownloadAndGetHtmlContentFromAttachmentFailure(
        exception: e,
        blobId: attachment.blobId,
        sourceView: sourceView,
      ));
    }
  }

  Future<Either<Failure, Success>?> _sanitizeHtmlContent(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Attachment attachment,
    AccountId accountId,
    Session session,
    DownloadSourceView? sourceView,
  ) async {
    try {
      final sanitizedHtmlContent = await _downloadAttachmentForWebInteractor
          .downloadRepository
          .sanitizeHtmlContent(htmlContent, transformConfiguration);

      return Right(DownloadAndGetHtmlContentFromAttachmentSuccess(
        sanitizedHtmlContent: sanitizedHtmlContent,
        htmlAttachmentTitle: attachment.generateFileName(),
        attachment: attachment,
        accountId: accountId,
        session: session,
        sourceView: sourceView,
      ));
    } catch (e) {
      return Left(DownloadAndGetHtmlContentFromAttachmentFailure(
        exception: e,
        blobId: attachment.blobId,
        sourceView: sourceView,
      ));
    }
  }
}