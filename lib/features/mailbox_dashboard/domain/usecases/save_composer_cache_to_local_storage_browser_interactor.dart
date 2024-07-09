import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_composer_cache_to_local_storage_browser_state.dart';

class SaveComposerCacheToLocalStorageBrowserInteractor {
  final ComposerCacheRepository _composerCacheRepository;
  final ComposerRepository _composerRepository;

  SaveComposerCacheToLocalStorageBrowserInteractor(
    this._composerCacheRepository,
    this._composerRepository,
  );

  Stream<Either<Failure, Success>> execute(
    CreateEmailRequest createEmailRequest,
    AccountId accountId,
    UserName userName,
  ) async* {
    try {
      yield Right<Failure, Success>(SaveComposerCacheToLocalStorageBrowserLoading());

      final emailCreated = await _composerRepository.generateEmail(createEmailRequest);
      final composerCache = ComposerCache(
        email: emailCreated,
        identity: createEmailRequest.identity,
        isRequestReadReceipt: createEmailRequest.isRequestReadReceipt,
        displayMode: createEmailRequest.displayMode);

      await _composerCacheRepository.saveComposerCacheToLocalStorageBrowser(
        composerCache,
        accountId,
        userName);

      yield Right<Failure, Success>(SaveComposerCacheToLocalStorageBrowserSuccess());
    } catch (exception) {
      yield Left<Failure, Success>(SaveComposerCacheToLocalStorageBrowserFailure(exception));
    }
  }
}
