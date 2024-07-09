import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_in_local_storage_browser_state.dart';

class GetComposerCacheInLocalStorageBrowserInteractor {
  final ComposerCacheRepository _composerCacheRepository;

  GetComposerCacheInLocalStorageBrowserInteractor(this._composerCacheRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      yield Right(GetComposerCacheInLocalStorageBrowserLoading());
      final composerCache = await _composerCacheRepository.getComposerCacheInLocalStorageBrowser(accountId, userName);
      yield Right(GetComposerCacheInLocalStorageBrowserSuccess(composerCache));
    } catch (exception) {
      yield Left(GetComposerCacheInLocalStorageBrowserFailure(exception));
    }
  }
}