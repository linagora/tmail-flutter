import 'package:core/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/email_state_change_source.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context_extension.dart';
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

/// Owns search refreshes for the lifetime of the dashboard widget.
@riverpod
SearchRefreshCoordinator? searchRefreshCoordinator(Ref ref) {
  final stateSource = ref.watch(dashboardEmailStateChangeSourceProvider);
  if (stateSource == null) return null;

  final coordinator = SearchRefreshCoordinator(
    executor: ref.read(searchExecutorServiceProvider),
    stateSource: stateSource,
    callbacks: SearchRefreshCoordinatorCallbacks(
      resolveDispatchContext: () => _resolveDispatchContext(ref),
      isSearchRunning: () =>
          ref.read(searchViewStateProvider).isSearchEmailRunning,
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

/// Builds the refresh dispatch context from the currently-bound dashboard.
/// Null until a session and account are available.
SearchDispatchContext? _resolveDispatchContext(Ref ref) {
  final dashboard = getBinding<MailboxDashBoardController>();
  if (dashboard == null) return null;

  return dashboard.buildSearchDispatchContext(
    collapseThreads: ref.read(localSettingsProvider).threadConfig.isEnabled,
  );
}
