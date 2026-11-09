import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_switch_loading_dialog_visible_notifier.g.dart';

/// True while the switch loading dialog route is on screen (including min-visible).
@riverpod
class AccountSwitchLoadingDialogVisibleNotifier
    extends _$AccountSwitchLoadingDialogVisibleNotifier {
  @override
  bool build() => false;

  void setVisible(bool visible) => state = visible;
}
