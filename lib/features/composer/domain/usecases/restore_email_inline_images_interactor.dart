import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/composer/domain/state/restore_email_inline_images_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class RestoreEmailInlineImagesInteractor {
  RestoreEmailInlineImagesInteractor(this._composerCacheRepository);

  final ComposerCacheRepository _composerCacheRepository;

  Stream<Either<Failure, Success>> execute({
    required String htmlContent,
    required TransformConfiguration transformConfiguration,
    required Map<String, String> mapUrlDownloadCID
  }) async* {
    try {
      yield Right(RestoringEmailInlineImages());
      
      final emailContent = await _composerCacheRepository.restoreEmailInlineImages(
        htmlContent,
        transformConfiguration,
        mapUrlDownloadCID);
      yield Right(RestoreEmailInlineImagesSuccess(emailContent));
    } catch (exception) {
      yield Left(RestoreEmailInlineImagesFailure(exception: exception));
    }
  }
}