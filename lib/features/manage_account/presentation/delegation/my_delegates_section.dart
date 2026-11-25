import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/my_delegates_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// "My delegates" tab of Settings › Delegation: who can use my mailbox. See ADR-0115.
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
                  _buildList(value),
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
      // Disabled until the add dialog ships.
      action: LinagoraEmptyCardAction(label: l10n.addDelegate, icon: Icons.add, onPressed: null),
    );
  }

  Widget _buildList(List<Delegate> delegates) {
    return LinagoraTileGroup(
      key: const ValueKey(UiKeys.myDelegatesList),
      children: [
        for (final delegate in delegates)
          LinagoraPersonTile(
            name: delegate.username,
            avatar: accountSwitcherAvatar(delegate.username, 40),
          ),
      ],
    );
  }

  Widget _buildAddButton(AppLocalizations l10n) {
    return LinagoraButton(
      key: const ValueKey(UiKeys.myDelegatesAddButton),
      label: l10n.addDelegate,
      icon: Icons.add,
      // Disabled until the add dialog ships.
      onPressed: null,
    );
  }
}
