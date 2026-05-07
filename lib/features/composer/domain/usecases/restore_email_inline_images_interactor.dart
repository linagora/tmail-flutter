import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/composer/domain/state/restore_email_inline_images_state.dart';
import 'package:tmail_ui_user/features/composer/domain/transformer/html_email_transformer.dart';

class RestoreEmailInlineImagesInteractor {
  final HtmlEmailTransformer _htmlEmailTransformer;

  RestoreEmailInlineImagesInteractor(this._htmlEmailTransformer);

  Stream<Either<Failure, Success>> execute({
    required String htmlContent,
    required TransformConfiguration transformConfiguration,
    required Map<String, String> mapUrlDownloadCID,
  }) async* {
    try {
      yield Right(RestoringEmailInlineImages());

      final emailContent = await _htmlEmailTransformer.transformToHtml(
        htmlContent: htmlContent,
        transformConfiguration: transformConfiguration,
        mapCidImageDownloadUrl: mapUrlDownloadCID,
      );
      yield Right(RestoreEmailInlineImagesSuccess(emailContent));
    } catch (exception) {
      yield Left(RestoreEmailInlineImagesFailure(exception: exception));
    }
  }
}
