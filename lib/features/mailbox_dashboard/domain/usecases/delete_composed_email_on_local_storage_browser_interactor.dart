import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/delete_composed_email_on_local_storage_browser_state.dart';

class DeleteComposedEmailOnLocalStorageBrowserInteractor {
  final ComposerCacheRepository _composerCacheRepository;

  DeleteComposedEmailOnLocalStorageBrowserInteractor(this._composerCacheRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(DeleteComposedEmailOnLocalStorageBrowserLoading());
      await _composerCacheRepository.deleteComposedEmailOnLocalStorageBrowser();
      yield Right<Failure, Success>(DeleteComposedEmailOnLocalStorageBrowserSuccess());
    } catch (exception) {
      yield Left<Failure, Success>(DeleteComposedEmailOnLocalStorageBrowserFailure(exception));
    }
  }
}
