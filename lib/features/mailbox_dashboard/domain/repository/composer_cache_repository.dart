import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract class ComposerCacheRepository {
  void saveComposerCacheOnWeb(Email email);

  ComposerCache? getComposerCacheOnWeb();

  void removeComposerCacheOnWeb();
}
