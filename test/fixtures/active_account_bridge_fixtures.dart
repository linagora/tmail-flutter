import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_bridge.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

class ActiveAccountBridgeFixtures {
  /// Registers an [ActiveAccountBridge] on its own container that shows [shownAccountId] of [session],
  /// or my own account when it is null. The container is disposed after the test.
  static ActiveAccountBridge put(Session session, {AccountId? shownAccountId}) {
    final container = _newContainer();
    final bridge = ActiveAccountBridge(container)..applySession(session);
    if (shownAccountId != null) {
      container.read(activeAccountProvider.notifier).select(shownAccountId);
    }
    return _register(bridge);
  }

  /// Registers [showing] of [accountId].
  static ActiveAccountBridge putShowing(AccountId? accountId) => _register(showing(accountId));

  /// An unregistered [ActiveAccountBridge] that only carries [accountId], for a test whose session
  /// does not list that account. The container is disposed after the test.
  static ActiveAccountBridge showing(AccountId? accountId) {
    return ActiveAccountBridge(_newContainer())..accountId.value = accountId;
  }

  /// Shows [accountId] on the registered bridge until the end of the current test.
  static void showForThisTest(AccountId accountId) {
    final bridge = Get.find<ActiveAccountBridge>();
    final previousAccountId = bridge.accountId.value;
    bridge.accountId.value = accountId;
    addTearDown(() => bridge.accountId.value = previousAccountId);
  }

  static ProviderContainer _newContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  /// Replaces a bridge left registered by an earlier test, which [Get.put] would keep.
  static ActiveAccountBridge _register(ActiveAccountBridge bridge) {
    if (Get.isRegistered<ActiveAccountBridge>()) {
      Get.delete<ActiveAccountBridge>(force: true);
    }
    return Get.put(bridge);
  }
}
