
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

extension ListEmailCacheExtension on List<EmailCache> {
  Map<String, EmailCache> toMap() {
    return { for (var emailCache in this) emailCache.id : emailCache };
  }
}