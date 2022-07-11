import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class GetComposerCacheOnWebInteractor {
  final ComposerCacheRepository composerCacheRepository;

  GetComposerCacheOnWebInteractor(this.composerCacheRepository);

  ComposerCache? execute() {
    return composerCacheRepository.getComposerCacheOnWeb();
  }
}