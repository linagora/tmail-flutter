import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract interface class ComposerReloadCacheRepository {
  // Completes the browser storage write before returning from beforeunload.
  void saveSync(Session session, AccountId accountId, ComposerCache cache);
}
