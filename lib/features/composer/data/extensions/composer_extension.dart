import 'package:model/composer/composer.dart';
import 'package:tmail_ui_user/features/composer/data/model/composer_cache.dart';

extension ComposerExtensions on Composer {
  ComposerCache toCache() {
    return ComposerCache(
      emailActionType: emailActionType,
      presentationEmail: presentationEmail,
      emailContents: emailContents,
      attachments: attachments,
      mailboxRole: mailboxRole,
      emailAddress: emailAddress,
    );
  }
}
