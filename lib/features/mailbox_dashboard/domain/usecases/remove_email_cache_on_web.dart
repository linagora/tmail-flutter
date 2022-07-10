import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/email_cache_repository.dart';

class RemoveEmailCacheOnWebInteractor {
  final EmailCacheRepository emailCacheRepository;

  RemoveEmailCacheOnWebInteractor(this.emailCacheRepository);

  execute() {
    return emailCacheRepository.removeEmailCacheOnWeb();
  }
}