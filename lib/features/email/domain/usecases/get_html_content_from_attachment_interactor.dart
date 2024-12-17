import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/string_convert.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';

class GetHtmlContentFromAttachmentInteractor {
  GetHtmlContentFromAttachmentInteractor(this._downloadAttachmentForWebInteractor);

  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Attachment attachment,
    DownloadTaskId taskId,
    String baseDownloadUrl,
    TransformConfiguration transformConfiguration,
  ) async* {
    final onReceiveController = StreamController<Either<Failure, Success>>();
    try {
      yield Right(GettingHtmlContentFromAttachment(attachment: attachment));
      final downloadState = await _downloadAttachmentForWebInteractor.execute(
        taskId,
        attachment,
        accountId,
        baseDownloadUrl,
        onReceiveController,
      ).last;
      
      Either<Failure, Success>? sanitizeState;
      await downloadState.fold(
        (failure) {
          sanitizeState = Left(GetHtmlContentFromAttachmentFailure(
            exception: failure is FeatureFailure ? failure.exception : null,
            attachment: attachment,
          ));
        },
        (success) async {
          if (success is! DownloadAttachmentForWebSuccess) {
            sanitizeState = Right(GettingHtmlContentFromAttachment(attachment: attachment));
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
            );
          }
        },
      );

      onReceiveController.close();
      if (sanitizeState != null) {
        yield sanitizeState!;
      } else {
        yield Left(GetHtmlContentFromAttachmentFailure(
          exception: null,
          attachment: attachment,
        ));
      }
      
    } catch (e) {
      logError('GetHtmlContentFromAttachmentInteractor:exception: $e');
      onReceiveController.close();
      yield Left(GetHtmlContentFromAttachmentFailure(
        exception: e,
        attachment: attachment,
      ));
    }
  }

  Future<Either<Failure, Success>?> _sanitizeHtmlContent(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Attachment attachment,
  ) async {
    try {
      final sanitizedHtmlContent = await _downloadAttachmentForWebInteractor
        .emailRepository
        .sanitizeHtmlContent(
          htmlContent,
          transformConfiguration,
        );
      return Right(GetHtmlContentFromAttachmentSuccess(
        sanitizedHtmlContent: sanitizedHtmlContent,
        htmlAttachmentTitle: attachment.generateFileName(),
        attachment: attachment,
      ));
    } catch (e) {
      return Left(GetHtmlContentFromAttachmentFailure(
        exception: e,
        attachment: attachment,
      ));
    }
  }
}