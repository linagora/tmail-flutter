import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/dom/sanitize_hyper_link_tag_in_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/string_convert.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/download/domain/state/get_html_content_from_upload_file_state.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

class GetHtmlContentFromUploadFileInteractor {
  final DownloadRepository _downloadRepository;

  GetHtmlContentFromUploadFileInteractor(this._downloadRepository);

  Stream<Either<Failure, Success>> execute({
    required UploadFileState uploadFile,
    required Session? session,
    required AccountId? accountId,
  }) async* {
    try {
      yield Right(GettingHtmlContentFromUploadFile());

      final htmlContent = StringConvert.decodeFromBytes(
        uploadFile.file!.bytes!,
        charset: uploadFile.attachment!.charset,
        isHtml: true,
      );

      final sanitizedHtmlContent =
          await _downloadRepository.sanitizeHtmlContent(
        htmlContent,
        TransformConfiguration.create(
          customDomTransformers: [SanitizeHyperLinkTagInHtmlTransformer()],
          customTextTransformers: [
            const StandardizeHtmlSanitizingTransformers()
          ],
        ),
      );

      yield Right(GetHtmlContentFromUploadFileSuccess(
        sanitizedHtmlContent: sanitizedHtmlContent,
        htmlAttachmentTitle: uploadFile.attachment!.generateFileName(),
        attachment: uploadFile.attachment!,
        accountId: accountId,
        session: session,
      ));
    } catch (e) {
      yield Left(GetHtmlContentFromUploadFileFailure(exception: e));
    }
  }
}
