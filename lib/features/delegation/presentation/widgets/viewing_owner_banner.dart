import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_visibility.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// "Viewing [Owner] ✕" chip for the thread action row (Reload / Select all / Filter).
///
/// One owner avatar inside the pill. Stacked avatars stay on the top-right nav.
class ViewingOwnerBanner extends ConsumerWidget {
  static const Key bannerKey = ValueKey(UiKeys.viewingOwnerBanner);
  static const Key dismissKey = ValueKey(UiKeys.viewingOwnerBannerDismiss);

  /// Keeps long owner addresses from crowding the action row.
  static const double maxWidth = 280;

  const ViewingOwnerBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delegationEnabled = ref.watch(delegationEnabledProvider);
    final activeAccount = ref.watch(activeAccountProvider);
    final isSwitching = ref.watch(accountSwitchProvider).isSwitching;

    if (!canShowAccountSwitcher(
          delegationEnabled: delegationEnabled,
          session: activeAccount?.session,
        ) ||
        activeAccount == null ||
        !ShownAccountCapabilities.of(activeAccount).showsViewingOwnerChrome) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final ownerEmail = activeAccount.ownerEmailAddress;
    final label = l10n.viewingOwnerMailbox(ownerEmail);
    final chipStyle = LinagoraDismissibleChipStyle.material().copyWith(
      height: 34,
      dismissTargetSize: 32,
      iconSize: 16,
    );

    return IgnorePointer(
      ignoring: isSwitching,
      child: Opacity(
        opacity: isSwitching ? 0.5 : 1,
        child: ConstrainedBox(
          key: bannerKey,
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: LinagoraDismissibleChip(
            label: label,
            dismissTooltip: l10n.backToYourMailbox,
            dismissButtonKey: dismissKey,
            style: chipStyle,
            onDismissed: () => switchShownAccountOrToastFailure(
              context: context,
              ref: ref,
              shown: activeAccount,
              targetAccountId: activeAccount.personalAccountId,
            ),
            leading: accountSwitcherAvatar(ownerEmail, 20),
          ),
        ),
      ),
    );
  }
}
