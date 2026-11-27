import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/delegated_to_me_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

/// Lists the mailboxes delegated to me, each with "Remove your access".
class DelegatedToMeSection extends ConsumerStatefulWidget {
  final Session session;
  final OnSessionReloaded onSessionReloaded;

  const DelegatedToMeSection({
    super.key,
    required this.session,
    required this.onSessionReloaded,
  });

  @override
  ConsumerState<DelegatedToMeSection> createState() => _DelegatedToMeSectionState();
}

class _DelegatedToMeSectionState extends ConsumerState<DelegatedToMeSection> {
  @override
  void initState() {
    super.initState();
    // The provider cannot change while the tree builds.
    Future.microtask(_load);
  }

  void _load() {
    if (!mounted) return;
    ref.read(delegatedToMeProvider.notifier).load(widget.session, onSessionReloaded: widget.onSessionReloaded);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final delegatedAccounts = ref.watch(delegatedToMeProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.delegatedToMeExplanation,
            style: ThemeUtils.textStyleBodyBody3(color: AppColor.steelGrayA540),
          ),
          const SizedBox(height: 24),
          if (delegatedAccounts case AsyncData(:final value)) ...[
            _buildCountLabel(l10n, value.length),
            const SizedBox(height: 12),
          ],
          switch (delegatedAccounts) {
            AsyncData(:final value) when value.isEmpty => LinagoraEmptyCard(
                key: const ValueKey(UiKeys.delegatedToMeEmptyCard),
                illustration: _mailIllustration,
                title: l10n.noMailboxesSharedWithYou,
                message: l10n.noMailboxesSharedWithYouMessage,
              ),
            AsyncData(:final value) => _buildList(context, l10n, value),
            AsyncError() => LinagoraEmptyCard(
                title: l10n.couldNotLoadDelegatedMailboxes,
                action: LinagoraEmptyCardAction(label: l10n.retry, onPressed: _load),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ],
      ),
    );
  }

  static final Widget _mailIllustration = SvgPicture.asset(
    LinagoraDesignImages.emptyCardMailIcon,
    package: LinagoraDesignImages.packageName,
  );

  Widget _buildCountLabel(AppLocalizations l10n, int count) {
    return Row(
      children: [
        Flexible(
          child: Text(
            count == 0 ? l10n.mailboxesDelegatedToMe : l10n.mailboxesSharedWithMe,
            style: ThemeUtils.textStyleInter600().copyWith(fontSize: 14, color: Colors.black),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: const ShapeDecoration(
            color: AppColor.colorBackgroundWrapIconStyleCode,
            shape: StadiumBorder(),
          ),
          child: Text(
            '$count',
            style: ThemeUtils.textStyleInter500().copyWith(fontSize: 12, color: AppColor.steelGrayA540),
          ),
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    AppLocalizations l10n,
    List<DelegatedAccount> delegatedAccounts,
  ) {
    return LinagoraTileGroup(
      key: const ValueKey(UiKeys.delegatedToMeList),
      children: [
        for (final delegatedAccount in delegatedAccounts)
          LinagoraPersonTile(
            name: delegatedAccount.username,
            avatar: accountSwitcherAvatar(delegatedAccount.username, 40),
            action: LinagoraPersonTileAction(
              key: LinagoraPersonTile.actionKeyFor(delegatedAccount.username),
              tooltip: l10n.removeAccess,
              onPressed: () => _confirmRemove(context, delegatedAccount),
            ),
          ),
      ],
    );
  }

  void _confirmRemove(BuildContext context, DelegatedAccount delegatedAccount) {
    final l10n = AppLocalizations.of(context);
    MessageDialogActionManager().showConfirmDialogAction(
      context,
      title: l10n.removeYourAccessTitle,
      l10n.removeYourAccessMessage(delegatedAccount.username),
      l10n.removeAccess,
      alignCenter: true,
      cancelTitle: l10n.cancel,
      actionButtonColor: AppColor.redFF3347,
      additionalWidgetContent: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LinagoraTileGroup(
          children: [
            LinagoraPersonTile(
              name: delegatedAccount.username,
              avatar: accountSwitcherAvatar(delegatedAccount.username, 40),
            ),
          ],
        ),
      ),
      onConfirmAction: () => _remove(delegatedAccount),
      onCloseButtonAction: popBack,
    );
  }

  Future<void> _remove(DelegatedAccount delegatedAccount) async {
    final removed = await ref
        .read(delegatedToMeProvider.notifier)
        .remove(widget.session, delegatedAccount, onSessionReloaded: widget.onSessionReloaded);
    if (removed || !mounted) return;
    ref.read(appToastProvider).showToastErrorMessage(
          context,
          AppLocalizations.of(context).couldNotRemoveYourAccess,
        );
  }
}
