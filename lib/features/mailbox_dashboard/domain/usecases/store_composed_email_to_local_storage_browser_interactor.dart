import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_composed_email_to_local_storage_browser_state.dart';

class StoreComposedEmailToLocalStorageBrowserInteractor {
  final ComposerCacheRepository _composerCacheRepository;
  final ComposerRepository _composerRepository;

  StoreComposedEmailToLocalStorageBrowserInteractor(
    this._composerCacheRepository,
    this._composerRepository,
  );

  Stream<Either<Failure, Success>> execute(CreateEmailRequest createEmailRequest) async* {
    try {
      yield Right<Failure, Success>(StoreComposedEmailToLocalStorageBrowserLoading());
      final emailCreated = await _composerRepository.generateEmail(createEmailRequest);
      await _composerCacheRepository.storeComposedEmailToLocalStorageBrowser(emailCreated);
      yield Right<Failure, Success>(StoreComposedEmailToLocalStorageBrowserSuccess());
    } catch (exception) {
      yield Left<Failure, Success>(StoreComposedEmailToLocalStorageBrowserFailure(exception));
    }
  }
}
