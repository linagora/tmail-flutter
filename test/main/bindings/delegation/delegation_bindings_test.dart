import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/main/bindings/delegation/delegation_bindings.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import '../../../fixtures/delegation_fixtures.dart';

void main() {
  tearDown(() {
    appProviderContainer.read(activeAccountProvider.notifier).clear();
    Get.reset();
  });

  test('registers the source and its writer for the app lifetime, on the app provider container', () async {
    DelegationBindings().dependencies();

    appProviderContainer.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
    appProviderContainer.read(activeAccountProvider.notifier).select(DelegationFixtures.bobAccountId);

    expect(Get.find<ActiveAccountSource>().accountId, DelegationFixtures.bobAccountId);
    expect(Get.find<ActiveAccountWriter>(), same(Get.find<ActiveAccountSource>()));
    expect(await Get.delete<ActiveAccountSource>(), isFalse);
    expect(await Get.delete<ActiveAccountWriter>(), isFalse);
    expect(Get.isRegistered<ActiveAccountSource>(), isTrue);
    expect(Get.isRegistered<ActiveAccountWriter>(), isTrue);
  });

  test('registers the same source as the load reporter of the switch, for the app lifetime', () async {
    DelegationBindings().dependencies();

    expect(Get.find<ShownAccountLoadReporter>(), same(Get.find<ActiveAccountSource>()));
    expect(await Get.delete<ShownAccountLoadReporter>(), isFalse);
    expect(Get.isRegistered<ShownAccountLoadReporter>(), isTrue);
  });
}
