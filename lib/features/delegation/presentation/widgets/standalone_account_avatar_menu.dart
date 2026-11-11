import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_sections.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_visibility.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_icon.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_menu_overlay.dart'
    show OnProfileSettingActionTypeClick;
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

/// Stand-alone avatar menu with account sections when delegation is on.
class StandaloneAccountAvatarMenu extends ConsumerWidget {
  final String ownEmailAddress;
  final List<ProfileSettingActionType> settingActionTypes;
  final OnProfileSettingActionTypeClick onProfileSettingActionTypeClick;

  const StandaloneAccountAvatarMenu({
    super.key,
    required this.ownEmailAddress,
    required this.settingActionTypes,
    required this.onProfileSettingActionTypeClick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delegationEnabled = ref.watch(delegationEnabledProvider);
    final activeAccount = ref.watch(activeAccountProvider);

    if (!canShowAccountSwitcher(
      delegationEnabled: delegationEnabled,
      session: activeAccount?.session,
    )) {
      return ProfileSettingIcon(
        key: const ValueKey(UiKeys.userAvatar),
        ownEmailAddress: ownEmailAddress,
        settingActionTypes: settingActionTypes,
        onProfileSettingActionTypeClick: onProfileSettingActionTypeClick,
      );
    }

    return _DelegationAvatarMenu(
      activeAccount: activeAccount!,
      settingActionTypes: settingActionTypes,
      onProfileSettingActionTypeClick: onProfileSettingActionTypeClick,
    );
  }
}

class _DelegationAvatarMenu extends ConsumerStatefulWidget {
  final ActiveAccount activeAccount;
  final List<ProfileSettingActionType> settingActionTypes;
  final OnProfileSettingActionTypeClick onProfileSettingActionTypeClick;

  const _DelegationAvatarMenu({
    required this.activeAccount,
    required this.settingActionTypes,
    required this.onProfileSettingActionTypeClick,
  });

  @override
  ConsumerState<_DelegationAvatarMenu> createState() =>
      _DelegationAvatarMenuState();
}

class _DelegationAvatarMenuState extends ConsumerState<_DelegationAvatarMenu> {
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    _isExpandedNotifier.value = !_isExpandedNotifier.value;
  }

  void _closeMenu() {
    _isExpandedNotifier.value = false;
  }

  bool get _canManageAccount => widget.settingActionTypes
      .contains(ProfileSettingActionType.manageAccount);

  @override
  Widget build(BuildContext context) {
    final isSwitching = ref.watch(accountSwitchProvider).isSwitching;
    final shown = ref.watch(activeAccountProvider) ?? widget.activeAccount;
    final l10n = AppLocalizations.of(context);
    final style = LinagoraAccountSwitcherStyle.material().avatarMenu();
    final sections = buildAccountSwitcherSections(
      session: shown.session,
      l10n: l10n,
      avatarFor: (email) => accountSwitcherAvatar(email, style.tileStyle.avatarSize),
    );

    return ValueListenableBuilder(
      valueListenable: _isExpandedNotifier,
      builder: (context, isExpanded, _) {
        return IgnorePointer(
          ignoring: isSwitching,
          child: Opacity(
            opacity: isSwitching ? 0.5 : 1,
            child: PortalTarget(
              visible: isExpanded,
              portalFollower: PointerInterceptor(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeMenu,
                ),
              ),
              child: PortalTarget(
                anchor: Aligned(
                  follower: AppUtils.isDirectionRTL(context)
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  target: AppUtils.isDirectionRTL(context)
                      ? Alignment.bottomLeft
                      : Alignment.bottomRight,
                  offset: const Offset(0, 8),
                ),
                visible: isExpanded,
                // The composer editor is an iframe on web and takes the clicks of Flutter content above it.
                portalFollower: PointerInterceptor(
                  child: Material(
                    color: Colors.transparent,
                    child: LinagoraAccountMenuShell(
                      key: const ValueKey(UiKeys.accountSwitcherMenu),
                      style: style,
                      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                      child: LinagoraAccountMenu<AccountId>(
                        style: style,
                        sections: sections,
                        selectedId: shown.accountId,
                        onSelected: (accountId) {
                          _closeMenu();
                          FocusManager.instance.primaryFocus?.unfocus();
                          switchShownAccountOrToastFailure(
                            context: context,
                            ref: ref,
                            shown: shown,
                            targetAccountId: accountId,
                          );
                        },
                        header: LinagoraAccountMenuHeader(
                          style: style,
                          avatar: accountSwitcherAvatar(
                            shown.ownerEmailAddress,
                            style.headerAvatarSize,
                          ),
                          // ADR v1 is address-only. Header shows one line + copy.
                          name: shown.ownerEmailAddress,
                          email: null,
                          onCopyEmail: () => _copyEmail(shown.ownerEmailAddress),
                          copyTooltip: l10n.copy,
                          badge: ShownAccountCapabilities.of(shown)
                                  .showsViewingOwnerChrome
                              ? _delegatedBadge(l10n.delegatedMailbox)
                              : null,
                        ),
                        footer: _buildFooter(style: style, l10n: l10n),
                      ),
                    ),
                  ),
                ),
                child: _avatarTrigger(shown),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Single avatar on mine. Stacked mine+owner while viewing delegated (Figma).
  Widget _avatarTrigger(ActiveAccount shown) {
    // Nav trigger matches Figma (~40). Menu header uses DS headerAvatarSize.
    const size = 40.0;
    if (!ShownAccountCapabilities.of(shown).showsViewingOwnerChrome) {
      return Semantics(
        button: true,
        label: AppLocalizations.of(context).accountSwitcherMenu,
        child: (AvatarBuilder()
              ..text(shown.ownerEmailAddress.firstCharacterToUpperCase)
              ..backgroundColor(Colors.white)
              ..textColor(Colors.black)
              ..size(size)
              ..addOnTapActionClick(_toggleMenu)
              ..addBoxShadows([
                const BoxShadow(
                  color: AppColor.colorShadowBgContentEmail,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset.zero,
                ),
              ])
              ..key(const ValueKey(UiKeys.userAvatar)))
            .build(),
      );
    }

    final mineEmail = shown.session.getOwnEmailAddressOrEmpty();
    final stackStyle = LinagoraStackedAvatarsStyle.material().copyWith(
      size: size,
      overlap: 14,
    );
    final stack = LinagoraStackedAvatars(
      style: stackStyle,
      avatars: [
        accountSwitcherAvatar(shown.ownerEmailAddress, size),
        accountSwitcherAvatar(mineEmail, size),
      ],
    );
    // Tap layer on top: stacked avatar children otherwise swallow the hit.
    return SizedBox(
      width: size + (size - stackStyle.overlap),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          stack,
          Positioned.fill(
            child: Semantics(
              button: true,
              label: AppLocalizations.of(context).accountSwitcherMenu,
              child: GestureDetector(
                key: const ValueKey(UiKeys.userAvatar),
                behavior: HitTestBehavior.opaque,
                onTap: _toggleMenu,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter({
    required LinagoraAccountSwitcherStyle style,
    required AppLocalizations l10n,
  }) {
    return LinagoraAccountMenuActions(
      style: style,
      manageLabel: l10n.manage_account,
      signOutLabel: l10n.sign_out,
      // Null hides the Manage row in DS (blocked while delegated).
      onManageAccount: _canManageAccount
          ? () {
              _closeMenu();
              widget.onProfileSettingActionTypeClick(
                ProfileSettingActionType.manageAccount,
              );
            }
          : null,
      onSignOut: () {
        _closeMenu();
        widget.onProfileSettingActionTypeClick(
          ProfileSettingActionType.signOut,
        );
      },
    );
  }

  Widget _delegatedBadge(String label) {
    // Figma stand-alone: light blue pill, blue label.
    const blue = Color(0xFF0A84FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: blue,
        ),
      ),
    );
  }

  void _copyEmail(String email) {
    Clipboard.setData(ClipboardData(text: email));
    ref.read(appToastProvider).showToastSuccessMessage(
      context,
      AppLocalizations.of(context).email_address_copied_to_clipboard,
    );
  }
}

