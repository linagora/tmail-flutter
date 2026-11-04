import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class _CancelSwitchIntent extends Intent {
  const _CancelSwitchIntent();
}

/// Loading dialog while a delegated mailbox switch is in progress.
class AccountSwitchLoadingDialog extends StatelessWidget {
  final String ownerName;
  final VoidCallback onCancel;

  const AccountSwitchLoadingDialog({
    super.key,
    required this.ownerName,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _CancelSwitchIntent(),
      },
      child: Actions(
        actions: {
          _CancelSwitchIntent: CallbackAction<_CancelSwitchIntent>(
            onInvoke: (_) {
              onCancel();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) onCancel();
            },
            child: LinagoraDialog(
              title: appLocalizations.openingOwnerMailbox(ownerName),
              content: const CupertinoLoadingWidget(padding: EdgeInsets.only(top: 8)),
              primaryAction: LinagoraDialogAction(
                label: appLocalizations.cancel,
                onPressed: onCancel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
