import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/my_delegates_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/add_delegates/add_delegates_dialog.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/remove_delegate_dialog.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// "By me" tab of Settings › Delegation: my delegates, who can use my mailbox. See ADR-0115.
class MyDelegatesSection extends ConsumerStatefulWidget {
  final Session session;

  const MyDelegatesSection({super.key, required this.session});

  @override
  ConsumerState<MyDelegatesSection> createState() => _MyDelegatesSectionState();
}

class _MyDelegatesSectionState extends ConsumerState<MyDelegatesSection> {
  static final Widget _shareIllustration = SvgPicture.asset(
    LinagoraDesignImages.emptyCardShareIcon,
    package: LinagoraDesignImages.packageName,
  );

  @override
  void initState() {
    super.initState();
    // The provider cannot change while the tree builds.
    Future.microtask(_load);
  }

  void _load() {
    if (!mounted) return;
    ref.read(myDelegatesProvider.notifier).load(widget.session);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final delegates = ref.watch(myDelegatesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myDelegatesExplanation,
            style: ThemeUtils.textStyleBodyBody3(color: AppColor.steelGrayA540),
          ),
          const SizedBox(height: 24),
          ...switch (delegates) {
            AsyncData(:final value) => [
                Text(
                  l10n.whoHasAccessToYourMailbox,
                  style: ThemeUtils.textStyleInter500().copyWith(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 12),
                if (value.isEmpty)
                  _buildEmptyCard(l10n)
                else ...[
                  _buildList(l10n, value),
                  const SizedBox(height: 16),
                  _buildAddButton(l10n),
                ],
              ],
            AsyncError() => [
                LinagoraEmptyCard(
                  title: l10n.couldNotLoadDelegates,
                  action: LinagoraEmptyCardAction(label: l10n.retry, onPressed: _load),
                ),
              ],
            _ => [const Center(child: CircularProgressIndicator())],
          },
        ],
      ),
    );
  }

  Widget _buildEmptyCard(AppLocalizations l10n) {
    return LinagoraEmptyCard(
      key: const ValueKey(UiKeys.myDelegatesEmptyCard),
      illustration: _shareIllustration,
      title: l10n.noOneHasAccessYet,
      message: l10n.noOneHasAccessYetMessage,
      action: LinagoraEmptyCardAction(
        label: l10n.addDelegate,
        icon: Icons.add,
        onPressed: _openAddDialog,
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n, List<Delegate> delegates) {
    return LinagoraTileGroup(
      key: const ValueKey(UiKeys.myDelegatesList),
      children: [
        for (final delegate in delegates)
          LinagoraPersonTile(
            name: delegate.username,
            avatar: accountSwitcherAvatar(delegate.username, 40),
            action: LinagoraPersonTileAction(
              key: LinagoraPersonTile.actionKeyFor(delegate.username),
              tooltip: l10n.removeAccess,
              onPressed: () => _openRemoveDialog(delegate),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton(AppLocalizations l10n) {
    // Same button as the empty card's, since the app theme's primary is not the brand blue.
    final tokens = LinagoraEmptyCardStyle.material();
    return LinagoraButton(
      key: const ValueKey(UiKeys.myDelegatesAddButton),
      label: l10n.addDelegate,
      icon: Icons.add,
      onPressed: _openAddDialog,
      minimumHeight: tokens.actionHeight,
      padding: tokens.actionButtonPadding,
      iconSize: tokens.actionIconSize,
      backgroundColor: tokens.actionBackgroundColor,
      foregroundColor: tokens.actionForegroundColor,
    );
  }

  void _openAddDialog() {
    AddDelegatesDialog.show(AddDelegatesDialog(
      session: widget.session,
      loadSuggestions: _loadSuggestions,
      onDelegatesAdded: (result) => _showReread(result.delegates),
      onAddFailed: _load,
    ));
  }

  void _openRemoveDialog(Delegate delegate) {
    RemoveDelegateDialog.show(RemoveDelegateDialog(
      session: widget.session,
      delegate: delegate,
      onDelegateRemoved: (result) => _showReread(result.delegates),
      onRemoveFailed: _load,
    ));
  }

  /// Shows the list the add or remove request re-read.
  void _showReread(List<Delegate>? delegates) {
    if (!mounted) return;
    // A failed re-read leaves the list stale, so read it again.
    if (delegates == null) return _load();
    ref.read(myDelegatesProvider.notifier).show(delegates);
  }

  Future<List<EmailAddress>> _loadSuggestions(String query, {int? limit}) async {
    final interactor = ref.read(delegateAutoCompleteInteractorProvider);
    if (interactor == null) return [];
    final result = await interactor.execute(AutoCompletePattern(
      word: query,
      limit: limit,
      accountId: widget.session.accountId,
    ));
    return result.fold(
      (_) => [],
      (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : [],
    );
  }
}
