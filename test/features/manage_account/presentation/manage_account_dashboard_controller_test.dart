import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import '../../../fixtures/active_account_source_fixtures.dart';
import '../../../fixtures/base_controller_fixtures.dart';
import '../../../fixtures/delegation_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';
import 'manage_account_dashboard_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetQuotasInteractor>(),
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetAuthenticatedAccountInteractor>(),
  MockSpec<UpdateAccountCacheInteractor>(),
  MockSpec<GetOidcUserInfoInteractor>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetQuotasInteractor getQuotasInteractor;

  setUp(() {
    BaseControllerFixtures.registerDependencies();
    Get.put<GetSessionInteractor>(MockGetSessionInteractor());
    Get.put<GetAuthenticatedAccountInteractor>(MockGetAuthenticatedAccountInteractor());
    Get.put<UpdateAccountCacheInteractor>(MockUpdateAccountCacheInteractor());
    Get.put<GetOidcUserInfoInteractor>(MockGetOidcUserInfoInteractor());
    // Kept by the lazy bindings Settings injects for its storage menu.
    getQuotasInteractor = MockGetQuotasInteractor();
    Get.put<GetQuotasInteractor>(getQuotasInteractor);
    when(getQuotasInteractor.execute(any)).thenAnswer((_) => const Stream.empty());
  });

  tearDown(Get.reset);

  ManageAccountDashBoardController openSettingsWith(Session session) {
    Get.routing.args = ManageAccountArguments(session);
    addTearDown(() => Get.routing.args = null);
    return ManageAccountDashBoardController()..onReady();
  }

  test('Settings opened from a delegated mailbox loads the quota of my own account', () {
    ActiveAccountSourceFixtures.put(
      DelegationFixtures.session(),
      shownAccountId: DelegationFixtures.bobAccountId,
    );

    openSettingsWith(DelegationFixtures.session());

    verify(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).called(1);
    verifyNoMoreInteractions(getQuotasInteractor);
  });

  test('Settings loads no quota when my own account has no quota capability', () {
    openSettingsWith(SessionFixtures.aliceSession);

    verifyNever(getQuotasInteractor.execute(any));
  });

  test('Settings keeps the session re-read after removing my access for the dashboard', () {
    final controller = openSettingsWith(DelegationFixtures.session());
    final reRead = DelegationFixtures.session(state: 'state-2', listsBob: false);

    controller.applyReloadedSession(reRead);

    expect(controller.sessionCurrent, reRead);
  });

  group('a delegation link read before the local settings load', () {
    ManageAccountMenuController openDelegationLinkWhileHidden(ManageAccountDashBoardController controller) {
      Get.parameters = {RouteUtils.paramType: AccountMenuItem.delegation.getAliasBrowser()};
      addTearDown(() {
        Get.parameters = {};
        appProviderContainer.read(localSettingsProvider.notifier).update(PreferencesSetting.initial());
      });
      Get.put(controller);
      final menuController = Get.put(ManageAccountMenuController());
      controller.handleReloaded(DelegationFixtures.session());
      return menuController;
    }

    void loadStorageQuota(ManageAccountDashBoardController controller) {
      controller.octetsQuota.value = Quota(
        Id('storage'),
        ResourceType.octets,
        Scope.account,
        'Storage',
        used: UnsignedInt(1),
        hardLimit: UnsignedInt(100),
      );
    }

    test('opens Delegation once the settings turn it on', () {
      final controller = openSettingsWith(DelegationFixtures.session());
      openDelegationLinkWhileHidden(controller);

      DelegationFixtures.turnDelegationOn(appProviderContainer);

      expect(controller.accountMenuItemSelected.value, AccountMenuItem.delegation);
    });

    test('keeps Delegation open when the quota loads after it opened', () {
      final controller = openSettingsWith(DelegationFixtures.session());
      openDelegationLinkWhileHidden(controller);
      DelegationFixtures.turnDelegationOn(appProviderContainer);

      loadStorageQuota(controller);

      expect(controller.accountMenuItemSelected.value, AccountMenuItem.delegation);
    });

    test('does not reopen Delegation when the quota loads after Delegation was turned off', () {
      final controller = openSettingsWith(DelegationFixtures.session());
      openDelegationLinkWhileHidden(controller);
      DelegationFixtures.turnDelegationOn(appProviderContainer);
      appProviderContainer
          .read(localSettingsProvider.notifier)
          .update(PreferencesSetting([DelegationConfig(isEnabled: false)]));

      loadStorageQuota(controller);

      expect(controller.accountMenuItemSelected.value, AccountMenuItem.none);
    });

    test('does not open Delegation when it is turned on later, after the settings loaded', () {
      final controller = openSettingsWith(DelegationFixtures.session());
      openDelegationLinkWhileHidden(controller);
      appProviderContainer.read(localSettingsProvider.notifier).update(PreferencesSetting([]));

      DelegationFixtures.turnDelegationOn(appProviderContainer);

      expect(controller.accountMenuItemSelected.value, isNot(AccountMenuItem.delegation));
    });
  });
}
