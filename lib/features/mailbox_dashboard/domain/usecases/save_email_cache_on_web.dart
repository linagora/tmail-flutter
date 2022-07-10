import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/email_cache_repository.dart';

class SaveEmailCacheOnWebInteractor {
  final EmailCacheRepository emailCacheRepository;

  SaveEmailCacheOnWebInteractor(this.emailCacheRepository);

   execute(Email email) {
    return emailCacheRepository.saveEmailCacheOnWeb(email);
  }
}