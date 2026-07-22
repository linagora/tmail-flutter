import 'package:core/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/email_state_change_source.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_refresh_coordinator.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_executor_provider.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

part 'search_refresh_providers.g.dart';

/// Resolves the dashboard email-state source while the dashboard is bound.
@riverpod
DashboardEmailStateChangeSource? dashboardEmailStateChangeSource(Ref ref) {
  final dashboard = getBinding<MailboxDashBoardController>();
  if (dashboard == null) return null;
  return DashboardEmailStateChangeSource(dashboard);
}

/// Builds the current arguments required by a search refresh dispatch.
@riverpod
SearchDispatchContext? searchDispatchContext(Ref ref) {
  final dashboard = getBinding<MailboxDashBoardController>();
  final session = dashboard?.sessionCurrent;
  final accountId = dashboard?.accountId.value;
  if (session == null || accountId == null) return null;

  return SearchDispatchContext(
    session: session,
    accountId: accountId,
    properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId),
    collapseThreads:
        ref.read(localSettingsProvider).threadConfig.isEnabled,
    trashSpamMailboxIds: dashboard?.trashSpamMailboxIds,
  );
}

/// Owns search refreshes for the lifetime of the dashboard widget.
@riverpod
SearchRefreshCoordinator? searchRefreshCoordinator(Ref ref) {
  final stateSource = ref.watch(dashboardEmailStateChangeSourceProvider);
  if (stateSource == null) return null;

  final coordinator = SearchRefreshCoordinator(
    executor: ref.read(searchExecutorServiceProvider),
    stateSource: stateSource,
    callbacks: SearchRefreshCoordinatorCallbacks(
      resolveDispatchContext: () => ref.read(searchDispatchContextProvider),
      isSearchActive: () => ref.read(searchViewStateProvider).isSearchActive,
      resolveResultCount: () =>
          ref.read(searchEmailProvider).value?.emails.length ?? 0,
      onError: (error, stackTrace) => logWarning(
        'SearchRefreshCoordinator::_processMessage: $error\n$stackTrace',
      ),
    ),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
}
