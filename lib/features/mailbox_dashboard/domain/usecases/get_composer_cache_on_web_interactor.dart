import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';

class GetComposerCacheOnWebInteractor {
  final ComposerCacheRepository composerCacheRepository;

  GetComposerCacheOnWebInteractor(this.composerCacheRepository);

  Either<Failure, Success> execute() {
    try {
      final data = composerCacheRepository.getComposerCacheOnWeb();
      return Right(GetComposerCacheSuccess(data));
    } catch (exception) {
      return Left(GetComposerCacheFailure(exception));
    }
  }
}