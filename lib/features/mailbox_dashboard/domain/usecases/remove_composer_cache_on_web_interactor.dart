import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_composer_cache_state.dart';

class RemoveComposerCacheOnWebInteractor {
  final ComposerCacheRepository composerCacheRepository;

  RemoveComposerCacheOnWebInteractor(this.composerCacheRepository);

  Either<Failure, Success> execute() {
    try {
      composerCacheRepository.removeComposerCacheOnWeb();
      return Right(RemoveComposerCacheSuccess());
    } catch (exception) {
      return Left(RemoveComposerCacheFailure(exception));
    }
  }
}
