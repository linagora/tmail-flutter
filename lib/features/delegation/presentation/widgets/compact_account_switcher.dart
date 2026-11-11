import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_sections.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_visibility.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Avatar + chevron account switcher for the mobile and tablet web thread app bar.
class CompactAccountSwitcher extends ConsumerWidget {
  static const Key switcherKey = ValueKey(UiKeys.compactAccountSwitcher);

  const CompactAccountSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delegationEnabled = ref.watch(delegationEnabledProvider);
    final shown = ref.watch(activeAccountProvider);
    final isSwitching = ref.watch(accountSwitchProvider).isSwitching;

    if (shown == null ||
        !canShowAccountSwitcher(
          delegationEnabled: delegationEnabled,
          session: shown.session,
        )) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final style = LinagoraAccountSwitcherStyle.material().compact();

    return IgnorePointer(
      ignoring: isSwitching,
      child: Opacity(
        opacity: isSwitching ? 0.5 : 1,
        child: LinagoraAccountSwitcher<AccountId>(
          key: switcherKey,
          style: style,
          semanticLabel: l10n.accountSwitcherMenu,
          menuSemanticLabel: l10n.accountSwitcherMenu,
          avatar: accountSwitcherAvatar(
            shown.ownerEmailAddress,
            style.chipAvatarSize,
          ),
          sections: buildAccountSwitcherSections(
            session: shown.session,
            l10n: l10n,
            avatarFor: (email) =>
                accountSwitcherAvatar(email, style.tileStyle.avatarSize),
          ),
          selectedId: shown.accountId,
          onSelected: (accountId) {
            switchShownAccountOrToastFailure(
              context: context,
              ref: ref,
              shown: shown,
              targetAccountId: accountId,
            );
          },
        ),
      ),
    );
  }
}
