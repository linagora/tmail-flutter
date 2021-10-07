
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

extension ListEmailCacheExtension on List<EmailCache> {
  Map<String, EmailCache> toMap() {
    return Map<String, EmailCache>.fromIterable(
      this,
      key: (emailCache) => emailCache.id,
      value: (emailCache) => emailCache);
  }
}