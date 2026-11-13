import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class _CancelSwitchIntent extends Intent {
  const _CancelSwitchIntent();
}

/// Compact switch progress card. Typography and actions follow [LinagoraDialog].
class AccountSwitchLoadingDialog extends StatefulWidget {
  final String ownerName;
  final VoidCallback onCancel;
  final bool returningToMine;

  const AccountSwitchLoadingDialog({
    super.key,
    required this.ownerName,
    required this.onCancel,
    this.returningToMine = false,
  });

  /// Splits [message] around [ownerName] so the target can be bolded.
  @visibleForTesting
  static List<InlineSpan> openingMessageSpans({
    required String message,
    required String ownerName,
    required TextStyle baseStyle,
    FontWeight boldWeight = FontWeight.w700,
  }) {
    if (ownerName.isEmpty) {
      return [TextSpan(text: message, style: baseStyle)];
    }
    final index = message.indexOf(ownerName);
    if (index < 0) {
      return [TextSpan(text: message, style: baseStyle)];
    }
    return [
      if (index > 0)
        TextSpan(text: message.substring(0, index), style: baseStyle),
      TextSpan(
        text: ownerName,
        style: baseStyle.copyWith(fontWeight: boldWeight),
      ),
      if (index + ownerName.length < message.length)
        TextSpan(
          text: message.substring(index + ownerName.length),
          style: baseStyle,
        ),
    ];
  }

  @override
  State<AccountSwitchLoadingDialog> createState() =>
      _AccountSwitchLoadingDialogState();
}

class _AccountSwitchLoadingDialogState extends State<AccountSwitchLoadingDialog> {
  late final FocusNode _cancelFocusNode;

  @override
  void initState() {
    super.initState();
    _cancelFocusNode = FocusNode(debugLabel: 'account_switch_loading_cancel');
  }

  @override
  void dispose() {
    _cancelFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dialogStyle = LinagoraDialogStyle.material();
    final initial = widget.ownerName.firstCharacterToUpperCase;
    // Body size (16) + slightly darker label than the 90% dialog token.
    final statusTextStyle = dialogStyle.messageTextStyle.copyWith(
      color: const Color(0xFF424244),
    );

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
            child: Center(
              // Same outer margin as [LinagoraDialog.insetPadding].
              child: Padding(
                key: const ValueKey(UiKeys.accountSwitchLoadingDialog),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: dialogStyle.surfaceColor,
                        borderRadius:
                            BorderRadius.circular(dialogStyle.surfaceRadius),
                        boxShadow: dialogStyle.surfaceShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: dialogStyle.primaryActionColor,
                                      backgroundColor: dialogStyle
                                          .primaryActionColor
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: dialogStyle
                                        .primaryActionColor
                                        .withValues(alpha: 0.12),
                                    child: Text(
                                      initial,
                                      style: statusTextStyle.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: dialogStyle.primaryActionColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text.rich(
                              TextSpan(
                                children:
                                    AccountSwitchLoadingDialog
                                        .openingMessageSpans(
                                  message: widget.returningToMine
                                      ? l10n.openingYourMailbox
                                      : l10n.openingOwnerMailbox(
                                          widget.ownerName,
                                        ),
                                  // Bold the owner only when switching to them.
                                  ownerName: widget.returningToMine
                                      ? ''
                                      : widget.ownerName,
                                  baseStyle: statusTextStyle,
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            LinagoraButton(
                              key: const ValueKey(
                                UiKeys.accountSwitchLoadingCancel,
                              ),
                              label: l10n.cancel,
                              onPressed: widget.onCancel,
                              variant: LinagoraButtonVariant.filled,
                              height: dialogStyle.actionHeight,
                              padding: dialogStyle.actionPadding,
                              textStyle: dialogStyle.actionTextStyle,
                              // Match app cancel chips (Empty mailbox / confirm).
                              backgroundColor:
                                  AppColor.colorCancelPopupDialogButton,
                              foregroundColor: const Color(0xFF424244),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
