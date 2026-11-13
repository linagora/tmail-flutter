import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_sections.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_visibility.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Workplace header chip that switches the shown mailbox (#4977 §8).
///
/// Hidden while delegation is off or the session has no delegated account.
/// Disabled for the duration of a switch. Reuses T-07 switch wiring and toast.
class WorkplaceAccountSwitcher extends ConsumerWidget {
  const WorkplaceAccountSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delegationEnabled = ref.watch(delegationEnabledProvider);
    final activeAccount = ref.watch(activeAccountProvider);
    final isSwitching = ref.watch(accountSwitchProvider).isSwitching;

    if (!canShowAccountSwitcher(
      delegationEnabled: delegationEnabled,
      session: activeAccount?.session,
    )) {
      return const SizedBox.shrink();
    }

    final shown = activeAccount!;
    final l10n = AppLocalizations.of(context);
    final style = LinagoraAccountSwitcherStyle.material();
    final sections = buildAccountSwitcherSections(
      session: shown.session,
      l10n: l10n,
      avatarFor: (email) => accountSwitcherAvatar(email, style.tileStyle.avatarSize),
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: IgnorePointer(
        ignoring: isSwitching,
        child: Opacity(
          opacity: isSwitching ? 0.5 : 1,
          child: LinagoraAccountSwitcher<AccountId>(
            label: l10n.viewingOwnerMailbox(shown.ownerEmailAddress),
            avatar: accountSwitcherAvatar(
              shown.ownerEmailAddress,
              style.chipAvatarSize,
            ),
            sections: sections,
            selectedId: shown.accountId,
            menuSemanticLabel: l10n.accountSwitcherMenu,
            onSelected: (accountId) {
              // Unfocus before switchTo rebuilds the dashboard or web
              // ModalScope keeps a child whose enclosingScope is already null.
              FocusManager.instance.primaryFocus?.unfocus();
              switchShownAccountOrToastFailure(
                context: context,
                ref: ref,
                shown: shown,
                targetAccountId: accountId,
              );
            },
          ),
        ),
      ),
    );
  }
}
