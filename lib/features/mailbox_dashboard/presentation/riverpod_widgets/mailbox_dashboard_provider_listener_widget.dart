import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/adapters/trash_folder_adapter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/empty_folder_provider_listener_delegate.dart';

class MailboxDashboardProviderListenerWidget extends ConsumerWidget {
  final Widget child;
  final List<DashboardProviderListenerDelegate> delegates;

  MailboxDashboardProviderListenerWidget({
    super.key,
    required this.child,
    List<DashboardProviderListenerDelegate>? delegates,
  }) : delegates = delegates ?? [
          EmptyFolderProviderListenerDelegate(adapter: const TrashFolderAdapter()),
        ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    for (final delegate in delegates) {
      delegate.listen(context, ref);
    }
    return child;
  }
}
