import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/delete_composer_cache_in_local_storage_browser_state.dart';

class DeleteComposerCacheInLocalStorageBrowserInteractor {
  final ComposerCacheRepository _composerCacheRepository;

  DeleteComposerCacheInLocalStorageBrowserInteractor(this._composerCacheRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(DeleteComposeCacheInLocalStorageBrowserLoading());
      await _composerCacheRepository.deleteComposerCacheInLocalStorageBrowser();
      yield Right<Failure, Success>(DeleteComposeCacheInLocalStorageBrowserSuccess());
    } catch (exception) {
      yield Left<Failure, Success>(DeleteComposeCacheInLocalStorageBrowserFailure(exception));
    }
  }
}
