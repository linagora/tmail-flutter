import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/dialog/modal_list_action_button_widget.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/remove_delegate_submission.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/remove_delegate_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/delegation_dialog_frame.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnDelegateRemoved = void Function(RemoveDelegateResult result);

/// "Remove delegate access?" with the delegate's card, then one `Delegate/set` destroy. See ADR-0115.
class RemoveDelegateDialog extends ConsumerWidget {
  static final LinagoraDialogStyle _tokens = DelegationDialogFrame.tokens;

  final Session session;
  final Delegate delegate;
  final OnDelegateRemoved onDelegateRemoved;

  /// The outcome is unknown, so the caller marks its list stale.
  final VoidCallback onRemoveFailed;

  const RemoveDelegateDialog({
    super.key,
    required this.session,
    required this.delegate,
    required this.onDelegateRemoved,
    required this.onRemoveFailed,
  });

  static Future<void> show(RemoveDelegateDialog dialog) {
    return DialogRouter().openDialogModal(child: dialog, dialogLabel: UiKeys.removeDelegateDialog);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isRemoving = ref.watch(removeDelegateProvider);

    return DelegationDialogFrame(
      key: const ValueKey(UiKeys.removeDelegateDialog),
      title: l10n.removeDelegateAccessTitle,
      isBusy: isRemoving,
      content: _buildContent(l10n),
      footer: _buildFooter(context, ref, l10n, isRemoving),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.removeDelegateAccessMessage(delegate.username), style: _tokens.messageTextStyle),
        SizedBox(height: _tokens.contentGap),
        LinagoraTileGroup(
          children: [
            LinagoraPersonTile(
              name: delegate.username,
              avatar: accountSwitcherAvatar(delegate.username, 40),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isRemoving) {
    return ModalListActionButtonWidget(
      padding: _tokens.fixedFooterPadding,
      negativeLabel: l10n.cancel,
      positiveLabel: l10n.removeAccess,
      negativeKey: const ValueKey(UiKeys.removeDelegateCancelButton),
      positiveKey: const ValueKey(UiKeys.removeDelegateSubmitButton),
      positiveColor: AppColor.redFF3347,
      isPositiveActionEnabled: !isRemoving,
      isProgressing: isRemoving,
      onNegativeAction: () {
        if (!isRemoving) popBack();
      },
      onPositiveAction: () => _submit(context, ref),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(appToastProvider);
    switch (await ref.read(removeDelegateProvider.notifier).submit(session, delegate)) {
      case RemoveDelegateIgnored():
        return;
      case RemoveDelegateFailed():
        onRemoveFailed();
        if (context.mounted) toast.showToastErrorMessage(context, l10n.couldNotRemoveDelegate(delegate.username));
      case RemoveDelegateSucceeded(:final result):
        onDelegateRemoved(result);
        if (!context.mounted) return;
        toast.showToastSuccessMessage(context, l10n.delegateHasBeenRemoved(delegate.username));
        popBack();
    }
  }
}
