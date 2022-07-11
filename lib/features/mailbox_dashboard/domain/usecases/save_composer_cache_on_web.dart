import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class SaveComposerCacheOnWebInteractor {
  final ComposerCacheRepository composerCacheRepository;

  SaveComposerCacheOnWebInteractor(this.composerCacheRepository);

   execute(Email email) {
    return composerCacheRepository.saveComposerCacheOnWeb(email);
  }
}