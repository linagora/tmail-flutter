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

  const ShownAccountCapabilities._({
    required this.canOpenSettings,
    required this.canCreateFilter,
    required this.canCreateDefaultFolders,
    required this.canUseNotificationKeychain,
  });

  factory ShownAccountCapabilities.of(ActiveAccount? shownAccount) {
    final delegatedShown = shownAccount?.isDelegated == true;
    final personalShown = shownAccount?.isDelegated == false;
    return ShownAccountCapabilities._(
      canOpenSettings: !delegatedShown,
      canCreateFilter: !delegatedShown,
      canCreateDefaultFolders: personalShown,
      canUseNotificationKeychain: personalShown,
    );
  }

  @override
  List<Object?> get props => [
        canOpenSettings,
        canCreateFilter,
        canCreateDefaultFolders,
        canUseNotificationKeychain,
      ];
}
