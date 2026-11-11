import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

/// What the UI may offer for the shown account, per the ADR-0114 table. Call sites ask for a
/// feature here instead of reading `isDelegated`.
class ShownAccountCapabilities with EquatableMixin {
  /// Settings always open on my own account. Also true while no account is shown: a page load of
  /// `/settings` has no dashboard, so no shown account, and it starts on my own account.
  final bool canOpenSettings;

  /// Rule filters write to my own account, so they stay off while a delegated account is shown.
  /// True while no account is shown, so the gate matches today's behaviour before the first
  /// session is applied.
  final bool canCreateFilter;

  /// Missing default folders are created only while my own account is shown.
  final bool canCreateDefaultFolders;

  /// The iOS notification keychain is written only while my own account is shown.
  final bool canUseNotificationKeychain;

  /// My composer preferences (e.g. always request a read receipt) stay off while a delegated
  /// account is shown, so mail sent from it never picks up my setting.
  final bool canApplyMyComposerSettings;

  /// Viewing chrome (banner, stacked avatar, Delegated badge) while a delegated account is shown.
  final bool showsViewingOwnerChrome;

  /// The From picker keeps server default identities only for a delegated account that has no
  /// editable one, so my own account never offers them.
  final bool offersServerDefaultIdentities;

  /// The vacation banner holds and ends my own vacation, so it stays off while a delegated
  /// account is shown.
  final bool showsMyVacationBanner;

  /// `EmailRecoveryAction/set` carries no account id, so the server restores into my own account:
  /// recovery stays off while a delegated account is shown.
  final bool canRecoverDeletedMessages;

  /// Premium upgrades my own storage, so it is not offered on the quota of a delegated account.
  final bool offersMyPremium;

  const ShownAccountCapabilities._({
    required this.canOpenSettings,
    required this.canCreateFilter,
    required this.canCreateDefaultFolders,
    required this.canUseNotificationKeychain,
    required this.canApplyMyComposerSettings,
    required this.showsViewingOwnerChrome,
    required this.offersServerDefaultIdentities,
    required this.showsMyVacationBanner,
    required this.canRecoverDeletedMessages,
    required this.offersMyPremium,
  });

  factory ShownAccountCapabilities.of(ActiveAccount? shownAccount) {
    final delegatedShown = shownAccount?.isDelegated == true;
    final personalShown = shownAccount?.isDelegated == false;
    return ShownAccountCapabilities._(
      canOpenSettings: !delegatedShown,
      canCreateFilter: !delegatedShown,
      canCreateDefaultFolders: personalShown,
      canUseNotificationKeychain: personalShown,
      canApplyMyComposerSettings: !delegatedShown,
      showsViewingOwnerChrome: delegatedShown,
      offersServerDefaultIdentities: delegatedShown,
      showsMyVacationBanner: !delegatedShown,
      canRecoverDeletedMessages: !delegatedShown,
      offersMyPremium: !delegatedShown,
    );
  }

  @override
  List<Object?> get props => [
        canOpenSettings,
        canCreateFilter,
        canCreateDefaultFolders,
        canUseNotificationKeychain,
        canApplyMyComposerSettings,
        showsViewingOwnerChrome,
        offersServerDefaultIdentities,
        showsMyVacationBanner,
        canRecoverDeletedMessages,
        offersMyPremium,
      ];
}
