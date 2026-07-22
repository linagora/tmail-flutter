import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/empty_folder_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/search_refresh_coordinator_provider_listener_delegate.dart';

/// Provider listener delegates mounted by the mailbox dashboard.
const mailboxDashboardProviderListenerDelegateFactories =
    <DashboardDelegateFactory>[
  EmptyFolderProviderListenerDelegate.trash,
  SearchRefreshCoordinatorProviderListenerDelegate.new,
];
