import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import '../../../fixtures/active_account_bridge_fixtures.dart';
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

  void openSettingsWith(Session session) {
    Get.routing.args = ManageAccountArguments(session);
    addTearDown(() => Get.routing.args = null);
    ManageAccountDashBoardController().onReady();
  }

  test('Settings opened from a delegated mailbox loads the quota of my own account', () {
    ActiveAccountBridgeFixtures.put(
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
}
