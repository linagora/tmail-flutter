import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/switch_loading_dialog_timing.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/account_switch_loading_dialog.dart';

/// Shows the switch loading dialog above the dashboard once timing allows it.
class AccountSwitchLoadingDialogHost extends ConsumerStatefulWidget {
  final Widget child;

  const AccountSwitchLoadingDialogHost({super.key, required this.child});

  @override
  ConsumerState<AccountSwitchLoadingDialogHost> createState() =>
      _AccountSwitchLoadingDialogHostState();
}

class _AccountSwitchLoadingDialogHostState
    extends ConsumerState<AccountSwitchLoadingDialogHost> {
  late final SwitchLoadingDialogTiming _timing;
  DialogRoute<void>? _dialogRoute;
  AccountId? _targetAccountId;

  @override
  void initState() {
    super.initState();
    _timing = SwitchLoadingDialogTiming(onVisibilityChanged: _onVisibilityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncWithState(ref.read(accountSwitchProvider));
    });
  }

  @override
  void dispose() {
    _timing.dispose();
    _removeDialogRoute();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AccountSwitchState>(accountSwitchProvider, (_, next) {
      _syncWithState(next);
    });
    return widget.child;
  }

  void _syncWithState(AccountSwitchState state) {
    if (state is AccountSwitching) {
      _targetAccountId = state.attempt.to;
      _timing.switchStarted();
    } else {
      _timing.switchEnded();
    }
  }

  void _onVisibilityChanged(bool visible) {
    if (visible) {
      if (!mounted) return;
      _openDialog();
    } else {
      _removeDialogRoute();
    }
  }

  void _openDialog() {
    if (_dialogRoute != null || !mounted) return;
    final ownerName = _ownerNameFor(_targetAccountId);
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: LinagoraDialogStyle.barrierColor,
      builder: (dialogContext) {
        return AccountSwitchLoadingDialog(
          ownerName: ownerName,
          onCancel: () {
            if (!mounted) return;
            ref.read(accountSwitchProvider.notifier).cancel();
          },
        );
      },
    );
    _dialogRoute = route;
    navigator.push(route).whenComplete(() {
      if (identical(_dialogRoute, route)) _dialogRoute = null;
    });
  }

  void _removeDialogRoute() {
    final route = _dialogRoute;
    _dialogRoute = null;
    if (route != null && route.isActive) {
      route.navigator?.removeRoute(route);
    }
  }

  String _ownerNameFor(AccountId? accountId) {
    if (accountId == null) return '';
    final session = ref.read(activeAccountProvider)?.session;
    final account = session?.accounts[accountId];
    // Session accounts expose the owner's address as name; keep that as the fallback.
    return account?.name.value ?? '';
  }
}
