import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_composer_cache_by_id_state.dart';

class RemoveComposerCacheByIdInteractor {
  final ComposerCacheRepository _composerCacheRepository;

  RemoveComposerCacheByIdInteractor(this._composerCacheRepository);

  Future<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    String composerId,
  ) async {
    try {
      await _composerCacheRepository.removeComposerCacheById(
        accountId,
        userName,
        composerId,
      );
      return Right(RemoveComposerCacheByIdSuccess());
    } catch (exception) {
      return Left(RemoveComposerCacheByIdFailure(exception));
    }
  }
}
