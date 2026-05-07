import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_composer_cache_state.dart';

class SaveComposerCacheInteractor {
  final ComposerCacheRepository _composerCacheRepository;
  final ComposerRepository _composerRepository;

  SaveComposerCacheInteractor(
    this._composerCacheRepository,
    this._composerRepository,
  );

  Future<Either<Failure, Success>> execute({
    required CreateEmailRequest createEmailRequest,
    bool isPersistent = false,
  }) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true,
        isDraft: true,
      );
      final accountId = createEmailRequest.accountId;
      final userName = createEmailRequest.session.username;
      final composerCache = createEmailRequest.generateComposerCache(
        emailCreated: emailCreated,
        isPersistent: isPersistent,
      );
      await _composerCacheRepository.saveComposerCache(
        accountId,
        userName,
        composerCache,
      );
      return Right(SaveComposerCacheSuccess());
    } catch (exception) {
      return Left(SaveComposerCacheFailure(exception));
    }
  }
}
