import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';

class MailboxDashboardProviderListenerWidget extends ConsumerStatefulWidget {
  final Widget child;

  // Caller provides factory tear-offs (e.g. [EmptyFolderProviderListenerDelegate.trash]).
  // Adding a new feature (MarkAsRead, Spam, …) = create a new delegate + add its
  // factory to the caller's list. This widget and its State need no modification.
  final List<DashboardDelegateFactory> delegateFactories;

  const MailboxDashboardProviderListenerWidget({
    super.key,
    required this.child,
    required this.delegateFactories,
  });

  @override
  ConsumerState<MailboxDashboardProviderListenerWidget> createState() =>
      _MailboxDashboardProviderListenerWidgetState();
}

class _MailboxDashboardProviderListenerWidgetState
    extends ConsumerState<MailboxDashboardProviderListenerWidget> {
  late final List<DashboardProviderListenerDelegate> _delegates;

  @override
  void initState() {
    super.initState();
    _delegates = widget.delegateFactories.map((factory) => factory()).toList();
  }

  @override
  void dispose() {
    for (final delegate in _delegates) {
      delegate.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final delegate in _delegates) {
      delegate.listen(context, ref);
    }
    return widget.child;
  }
}
