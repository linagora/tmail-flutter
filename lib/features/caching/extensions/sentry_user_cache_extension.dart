import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';

extension SentryUserCacheExtension on SentryUserCache {
  SentryUser toSentryUser() {
    return SentryUser(
      id: id,
      name: name,
      username: username,
      email: email,
    );
  }
}
