
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension CleanupRecentSearchExtension on MailboxDashBoardController {
  void cleanupRecentSearch() {
    final cleanupRecentSearchCacheInteractor =
      getBinding<CleanupRecentSearchCacheInteractor>();
    final accountId = this.accountId.value;
    final username = sessionCurrent?.username;

    if (accountId == null || username == null || cleanupRecentSearchCacheInteractor == null) {
      logError('CleanupRecentSearchExtension::cleanupRecentSearch: accountId == null || username == null || cleanupRecentSearchCacheInteractor == null');
      return;
    }

    consumeState(cleanupRecentSearchCacheInteractor.execute(
      RecentSearchCleanupRule(accountId, username),
    ));
  }
}