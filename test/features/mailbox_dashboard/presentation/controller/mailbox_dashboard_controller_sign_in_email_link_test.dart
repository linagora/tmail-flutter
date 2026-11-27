import 'package:core/utils/platform_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/sign_in_email_link.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailto/presentation/model/mailto_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/sign_in_email_link_fixtures.dart';
import 'mailbox_dashboard_controller_test_harness.dart';

void main() {
  setUpMailboxDashboardControllerTest();

  group('a sign-in email link kept by an earlier forced logout:', () {
    final session = DelegationFixtures.session();
    final bob = DelegationFixtures.bobAccountId;
    late SessionStorageManager sessionStorage;

    setUp(() {
      dotenv.testLoad();
      PlatformInfo.isTestingForWeb = true;
      sessionStorage = Get.put(SessionStorageManager());
      when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
      when(labelController.isLabelSettingEnabled).thenReturn(RxBool(false));
    });

    tearDown(() {
      sessionStorage.remove(SignInEmailLink.storageKey);
      PlatformInfo.isTestingForWeb = false;
      Get.routing.args = null;
      Get.delete<SessionStorageManager>(force: true);
    });

    Future<void> putDashboard(WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await pumpLocalizedApp(tester, container: container);
      Get.delete<MailboxDashBoardController>(force: true);
      Get.put(mailboxDashboardController);
    }

    testWidgets(
      'WHEN the dashboard opens from a mailto link\n'
      'THEN the mailto target SHOULD survive the kept link',
      (tester) async {
        sessionStorage.save(SignInEmailLink.storageKey, '/dashboard?account=${bob.id.value}');
        await putDashboard(tester);
        // After the pump: GetMaterialApp resets the route arguments.
        Get.routing.args = MailtoArguments(session: session, mailtoUri: 'mailto:carol@domain.tld');

        // Get.put scheduled onReady for the next frame: it runs once, as on a real page load.
        await tester.pump();

        expect(
          mailboxDashboardController.routerParameters.value?[RouteUtils.paramRouteName],
          AppRoutes.mailtoURL,
          reason: 'the kept link replaces the mailto router map, so the composer never opens',
        );
      },
    );

    testWidgets(
      'WHEN Settings › Delegation was kept but the restored account is delegated\n'
      'THEN the link SHOULD NOT be dropped without opening Settings',
      (tester) async {
        sessionStorage.save(SignInEmailLink.storageKey, '/settings?type=delegation');
        await putDashboard(tester);
        // The shown account the dashboard restores: a delegated mailbox, where Settings is off.
        ActiveAccountSourceFixtures.put(session, shownAccountId: bob);
        expect(mailboxDashboardController.shownAccountCapabilities.canOpenSettings, isFalse);

        mailboxDashboardController.handleReloaded(session);
        await tester.pump();

        expect(
          isSignInEmailLinkKept() || Get.currentRoute.startsWith(AppRoutes.settings),
          isTrue,
          reason: 'the link is taken first, then _openSettings returns on canOpenSettings',
        );
      },
    );
  });
}
