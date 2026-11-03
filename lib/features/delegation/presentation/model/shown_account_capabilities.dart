import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

/// What the UI may offer for the shown account, per the ADR-0114 table. Call sites ask for a
/// feature here instead of reading `isDelegated`.
class ShownAccountCapabilities with EquatableMixin {
  /// Settings always open on my own account. Also true while no account is shown: a page load of
  /// `/settings` has no dashboard, so no shown account, and it starts on my own account.
  final bool canOpenSettings;

  /// Rule filters write to my own account, so they stay off while a delegated account is shown.
  final bool canCreateFilter;

  const ShownAccountCapabilities._({
    required this.canOpenSettings,
    required this.canCreateFilter,
  });

  factory ShownAccountCapabilities.of(ActiveAccount? shownAccount) {
    final isDelegated = shownAccount?.isDelegated == true;
    return ShownAccountCapabilities._(
      canOpenSettings: !isDelegated,
      canCreateFilter: !isDelegated,
    );
  }

  @override
  List<Object?> get props => [canOpenSettings, canCreateFilter];
}
