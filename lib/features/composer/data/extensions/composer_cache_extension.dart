import 'package:model/composer/composer.dart';
import 'package:tmail_ui_user/features/composer/data/model/composer_cache.dart';

extension ComposerCacheExtension on ComposerCache {
  Composer toComposer() {
    return Composer(
      emailActionType: emailActionType,
      presentationEmail: presentationEmail,
      emailContents: emailContents,
      attachments: attachments,
      mailboxRole: mailboxRole,
      emailAddress: emailAddress,
    );
  }
}
