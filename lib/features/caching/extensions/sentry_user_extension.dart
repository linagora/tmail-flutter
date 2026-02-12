import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';

extension SentryUserExtension on SentryUser {
  SentryUserCache toSentryUserCache() {
    return SentryUserCache(
      id: id ?? '',
      name: name ?? '',
      username: username ?? '',
      email: email ?? '',
    );
  }
}
