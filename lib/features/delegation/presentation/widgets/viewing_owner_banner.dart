import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_visibility.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

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
    // Tokens match DS material Viewing chip: #F5F6FA fill, no border, 6px radius.
    final chipStyle = LinagoraDismissibleChipStyle.material().copyWith(
      height: 34,
      padding: const EdgeInsetsDirectional.only(start: 8, end: 2),
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
            onDismissed: () => _switchToMine(context, ref, activeAccount),
            leading: _ownerAvatar(ownerEmail),
          ),
        ),
      ),
    );
  }

  Widget _ownerAvatar(String email) {
    const size = 20.0;
    return (AvatarBuilder()
          ..text(email.firstCharacterToUpperCase)
          ..size(size)
          ..avatarColor(email.gradientColors)
          ..addTextStyle(const TextStyle(
            color: Colors.white,
            fontSize: size * 0.44,
            fontWeight: FontWeight.w600,
          )))
        .build();
  }

  Future<void> _switchToMine(
    BuildContext context,
    WidgetRef ref,
    ActiveAccount activeAccount,
  ) async {
    final mineId = activeAccount.personalAccountId;
    final ownerDisplayName = activeAccount.session.getOwnEmailAddressOrEmpty();
    final view = ref.read(accountSwitchViewFactoryProvider)(context);
    final result = await ref
        .read(accountSwitchProvider.notifier)
        .switchTo(mineId, view);
    if (!context.mounted) return;
    showAccountSwitchFailureToast(
      context: context,
      appToast: ref.read(appToastProvider),
      args: AccountSwitchFailureToastArgs(
        result: result,
        ownerDisplayName: ownerDisplayName,
        returningToMine: true,
      ),
    );
  }
}
