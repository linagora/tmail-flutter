import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

/// What the UI may offer for the shown account, per the ADR-0114 table. Call sites ask for a
/// feature here instead of reading `isDelegated`.
class ShownAccountCapabilities with EquatableMixin {
  /// Settings always open on my own account. Also true while no account is shown: a page load of
  /// `/settings` has no dashboard, so no shown account, and it starts on my own account.
  final bool canOpenSettings;

  const ShownAccountCapabilities._({required this.canOpenSettings});

  factory ShownAccountCapabilities.of(ActiveAccount? shownAccount) {
    final isDelegatedAccountShown = shownAccount?.isDelegated == true;
    return ShownAccountCapabilities._(canOpenSettings: !isDelegatedAccountShown);
  }

  @override
  List<Object?> get props => [canOpenSettings];
}
