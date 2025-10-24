import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/dom/sanitize_hyper_link_tag_in_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/string_convert.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_html_content_from_upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

class GetHtmlContentFromUploadFileInteractor {
  final EmailRepository _emailRepository;

  GetHtmlContentFromUploadFileInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(UploadFileState uploadFile) async* {
    try {
      yield Right(GettingHtmlContentFromUploadFile());

      final htmlContent = StringConvert.decodeFromBytes(
        uploadFile.file!.bytes!,
        charset: uploadFile.attachment!.charset,
        isHtml: true,
      );

      final sanitizedHtmlContent = await _emailRepository.sanitizeHtmlContent(
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
      ));
    } catch (e) {
      yield Left(GetHtmlContentFromUploadFileFailure(exception: e));
    }
  }
}
