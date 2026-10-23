import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_bridge.dart';

/// For a GetX class that reads the shown mailbox. Settings and other personal areas use my own
/// account and never mix it in. See ADR-0114.
mixin ActiveAccountReader {
  ActiveAccountBridge get activeAccountBridge => Get.find<ActiveAccountBridge>();

  AccountId? get activeAccountId => activeAccountBridge.accountId.value;

  /// Calls [onShown] once a new dashboard has set [personalAccountId], at once when it is already
  /// set, then each time another account is shown. The bridge outlives a dashboard and keeps its
  /// value across a rebuild, so the first load waits for [personalAccountId], and the caller
  /// disposes the worker on close.
  Worker everShownAccount(
    Rxn<AccountId> personalAccountId,
    void Function(AccountId shownAccountId) onShown,
  ) {
    void showAccount() {
      final shownAccountId = activeAccountId;
      if (personalAccountId.value != null && shownAccountId != null) {
        onShown(shownAccountId);
      }
    }

    final worker = everAll([personalAccountId, activeAccountBridge.accountId], (_) => showAccount());
    showAccount();
    return worker;
  }
}
