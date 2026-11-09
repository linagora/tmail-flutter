import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_loading_dialog_visible_notifier.dart';
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
  static const _backInterceptorName = 'account_switch_loading';

  late final SwitchLoadingDialogTiming _timing;
  DialogRoute<void>? _dialogRoute;
  AccountId? _targetAccountId;
  bool _backInterceptorAdded = false;
  ProviderContainer? _container;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void dispose() {
    _removeBackInterceptor();
    _timing.dispose();
    final route = _dialogRoute;
    _dialogRoute = null;
    if (route != null && route.isActive) {
      route.navigator?.removeRoute(route);
    }
    final container = _container;
    if (container != null &&
        container.read(accountSwitchLoadingDialogVisibleProvider)) {
      container
          .read(accountSwitchLoadingDialogVisibleProvider.notifier)
          .setVisible(false);
    }
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
      _addBackInterceptor();
      _timing.switchStarted();
    } else {
      _removeBackInterceptor();
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
          onCancel: _cancelSwitch,
        );
      },
    );
    _dialogRoute = route;
    _setDialogVisible(true);
    navigator.push(route).whenComplete(() {
      if (identical(_dialogRoute, route)) _dialogRoute = null;
      if (mounted) _setDialogVisible(false);
    });
  }

  void _removeDialogRoute() {
    final route = _dialogRoute;
    _dialogRoute = null;
    if (route != null && route.isActive) {
      route.navigator?.removeRoute(route);
    }
    if (mounted) _setDialogVisible(false);
  }

  void _setDialogVisible(bool visible) {
    if (!mounted) return;
    if (ref.read(accountSwitchLoadingDialogVisibleProvider) == visible) return;
    ref.read(accountSwitchLoadingDialogVisibleProvider.notifier).setVisible(visible);
  }

  void _cancelSwitch() {
    if (!mounted) return;
    ref.read(accountSwitchProvider.notifier).cancel();
  }

  void _addBackInterceptor() {
    if (_backInterceptorAdded) return;
    BackButtonInterceptor.add(_onBackButton, name: _backInterceptorName);
    _backInterceptorAdded = true;
  }

  void _removeBackInterceptor() {
    if (!_backInterceptorAdded) return;
    BackButtonInterceptor.removeByName(_backInterceptorName);
    _backInterceptorAdded = false;
  }

  /// Android back during the show delay or while the dialog is up cancels the switch.
  bool _onBackButton(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    _cancelSwitch();
    return true;
  }

  String _ownerNameFor(AccountId? accountId) {
    if (accountId == null) return '';
    final session = ref.read(activeAccountProvider)?.session;
    final account = session?.accounts[accountId];
    // Session accounts expose the owner's address as name; keep that as the fallback.
    return account?.name.value ?? '';
  }
}
