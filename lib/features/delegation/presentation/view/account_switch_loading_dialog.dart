import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class _CancelSwitchIntent extends Intent {
  const _CancelSwitchIntent();
}

/// Loading dialog while a delegated mailbox switch is in progress.
class AccountSwitchLoadingDialog extends StatefulWidget {
  final String ownerName;
  final VoidCallback onCancel;

  const AccountSwitchLoadingDialog({
    super.key,
    required this.ownerName,
    required this.onCancel,
  });

  @override
  State<AccountSwitchLoadingDialog> createState() =>
      _AccountSwitchLoadingDialogState();
}

class _AccountSwitchLoadingDialogState extends State<AccountSwitchLoadingDialog> {
  late final FocusNode _cancelFocusNode;

  @override
  void initState() {
    super.initState();
    // LinagoraDialog's Cancel button has no autofocus API; keep a focused
    // scope so Escape / Enter / Space cancel without walking the element tree.
    _cancelFocusNode = FocusNode(debugLabel: 'account_switch_loading_cancel');
  }

  @override
  void dispose() {
    _cancelFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _CancelSwitchIntent(),
        SingleActivator(LogicalKeyboardKey.enter): _CancelSwitchIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): _CancelSwitchIntent(),
        SingleActivator(LogicalKeyboardKey.space): _CancelSwitchIntent(),
      },
      child: Actions(
        actions: {
          _CancelSwitchIntent: CallbackAction<_CancelSwitchIntent>(
            onInvoke: (_) {
              widget.onCancel();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _cancelFocusNode,
          autofocus: true,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) widget.onCancel();
            },
            child: LinagoraDialog(
              title: appLocalizations.openingOwnerMailbox(widget.ownerName),
              content: const CupertinoLoadingWidget(padding: EdgeInsets.only(top: 8)),
              primaryAction: LinagoraDialogAction(
                label: appLocalizations.cancel,
                onPressed: widget.onCancel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
