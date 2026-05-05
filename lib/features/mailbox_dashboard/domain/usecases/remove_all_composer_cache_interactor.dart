import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_all_composer_cache_state.dart';

class RemoveAllComposerCacheInteractor {
  final ComposerCacheRepository _composerCacheRepository;

  RemoveAllComposerCacheInteractor(this._composerCacheRepository);

  Future<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async {
    try {
      await _composerCacheRepository.removeAllComposerCache(accountId, userName);
      return Right(RemoveAllComposerCacheSuccess());
    } catch (exception) {
      return Left(RemoveAllComposerCacheFailure(exception));
    }
  }
}
