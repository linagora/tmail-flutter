import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_bridge.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/main/bindings/delegation/delegation_bindings.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import '../../../fixtures/delegation_fixtures.dart';

void main() {
  tearDown(() {
    appProviderContainer.read(activeAccountProvider.notifier).clear();
    Get.reset();
  });

  test('registers the bridge for the app lifetime, on the app provider container', () async {
    DelegationBindings().dependencies();

    appProviderContainer.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
    appProviderContainer.read(activeAccountProvider.notifier).select(DelegationFixtures.bobAccountId);

    expect(Get.find<ActiveAccountBridge>().accountId.value, DelegationFixtures.bobAccountId);
    expect(await Get.delete<ActiveAccountBridge>(), isFalse);
    expect(Get.isRegistered<ActiveAccountBridge>(), isTrue);
  });
}
