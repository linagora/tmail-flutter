import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_refresh_coordinator.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_refresh_providers.dart';

/// Keeps the search refresh provider alive while the dashboard is mounted.
class SearchRefreshCoordinatorProviderListenerDelegate
    implements DashboardProviderListenerDelegate {
  ProviderSubscription<SearchRefreshCoordinator?>? _subscription;

  @override
  /// Starts the coordinator provider subscription.
  void setup(WidgetRef ref, BuildContext Function() _) {
    _subscription = ref.listenManual<SearchRefreshCoordinator?>(
      searchRefreshCoordinatorProvider,
      (_, __) {},
      fireImmediately: true,
    );
  }

  @override
  /// Stops the coordinator provider subscription.
  void dispose() {
    _subscription?.close();
    _subscription = null;
  }
}
