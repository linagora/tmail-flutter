import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_composer_cache_state.dart';

class SaveComposerCacheOnWebInteractor {
  final ComposerCacheRepository _composerCacheRepository;
  final ComposerRepository _composerRepository;

  SaveComposerCacheOnWebInteractor(
    this._composerCacheRepository,
    this._composerRepository,
  );

  Future<Either<Failure, Success>> execute(CreateEmailRequest createEmailRequest) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(createEmailRequest);
      _composerCacheRepository.saveComposerCacheOnWeb(emailCreated);
      return Right(SaveComposerCacheSuccess());
    } catch (exception) {
      return Left(SaveComposerCacheFailure(exception));
    }
  }
}
