import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_composer_cache_state.dart';

class SaveComposerCacheOnWebInteractor {
  final ComposerCacheRepository composerCacheRepository;

  SaveComposerCacheOnWebInteractor(this.composerCacheRepository);

  execute(Email email) {
    try {
      composerCacheRepository.saveComposerCacheOnWeb(email);
      return const Right(SaveComposerCacheSuccess);
    } catch (exception) {
      return Left(SaveComposerCacheFailure(exception));
    }
  }
}