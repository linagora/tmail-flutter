import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composed_email_from_local_storage_browser_state.dart';

class GetComposedEmailFromLocalStorageBrowserInteractor {
  final ComposerCacheRepository _composerCacheRepository;

  GetComposedEmailFromLocalStorageBrowserInteractor(this._composerCacheRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GetComposedEmailFromLocalStorageBrowserLoading());
      final email = await _composerCacheRepository.getComposedEmailFromLocalStorageBrowser();
      yield Right(GetComposedEmailFromLocalStorageBrowserSuccess(email));
    } catch (exception) {
      yield Left(GetComposedEmailFromLocalStorageBrowserFailure(exception));
    }
  }
}