import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/sign_in_email_link.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';

/// The dashboard rewrites the location bar with history.replaceState when the shown account changes, which
/// leaves Get.currentRoute and Get.parameters on the page that was first opened. The link kept on a forced
/// logout must be the page the user is on, the one RouteUtils builds the location bar from.
void main() {
  final session = DelegationFixtures.session();
  final bob = DelegationFixtures.bobAccountId;
  late SessionStorageManager storage;

  setUp(() {
    PlatformInfo.isTestingForWeb = true;
    storage = Get.put(SessionStorageManager());
    storage.remove(SignInEmailLink.storageKey);
  });

  tearDown(() {
    storage.remove(SignInEmailLink.storageKey);
    PlatformInfo.isTestingForWeb = false;
    ActiveAccountSourceFixtures.unregister();
    Get.routing.current = '';
    Get.reset();
  });

  Future<void> openPage(WidgetTester tester, String initialRoute) => tester.pumpWidget(GetMaterialApp(
        initialRoute: initialRoute,
        getPages: [GetPage(name: AppRoutes.dashboard, page: () => const SizedBox.shrink())],
      ));

  testWidgets(
    'WHEN the user opened a delegated mailbox link, switched back to their own mailbox and the session ends\n'
    'THEN the kept link SHOULD NOT reopen the delegated mailbox',
    (tester) async {
      await openPage(tester, '${AppRoutes.dashboard}?account=${bob.id.value}');
      ActiveAccountSourceFixtures.putShowing(session.accountId)
          .show(session.accountId, ActiveAccount.personal(session));
      expect(RouteUtils.shownDelegatedAccountId, isNull, reason: 'the location bar no longer names bob');

      keepSignInEmailLinkOfCurrentPage();

      expect(
        takeSignInEmailLink()?.dashboardParameters?['account'],
        isNot(bob.id.value),
        reason: 'Get.parameters still holds the first page, so the stale account=bob link is kept',
      );
    },
  );

  testWidgets(
    'WHEN the user switched to a delegated mailbox inside the app and the session ends\n'
    'THEN the delegated mailbox SHOULD be kept for after the login',
    (tester) async {
      await openPage(tester, AppRoutes.dashboard);
      ActiveAccountSourceFixtures.putShowing(bob).show(bob, ActiveAccount.delegated(session, bob));
      expect(RouteUtils.shownDelegatedAccountId, bob, reason: 'the location bar names bob');

      keepSignInEmailLinkOfCurrentPage();

      expect(
        takeSignInEmailLink()?.dashboardParameters?['account'],
        bob.id.value,
        reason: 'Get.parameters has no account, so nothing is kept',
      );
    },
  );
}
