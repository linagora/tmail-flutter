import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/email_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/email_cache_repository.dart';

class GetEmailCacheOnWebInteractor {
  final EmailCacheRepository emailCacheRepository;

  GetEmailCacheOnWebInteractor(this.emailCacheRepository);

  EmailCache? execute() {
    return emailCacheRepository.getEmailCacheOnWeb();
  }
}