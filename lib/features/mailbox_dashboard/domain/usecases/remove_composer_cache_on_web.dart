import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class RemoveComposerCacheOnWebInteractor {
  final ComposerCacheRepository composerCacheRepository;

  RemoveComposerCacheOnWebInteractor(this.composerCacheRepository);

  execute() {
    return composerCacheRepository.removeComposerCacheOnWeb();
  }
}