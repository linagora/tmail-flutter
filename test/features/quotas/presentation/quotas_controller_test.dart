import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_bridge.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';

import '../../../fixtures/active_account_bridge_fixtures.dart';
import '../../../fixtures/base_controller_fixtures.dart';
import '../../../fixtures/delegation_fixtures.dart';
import 'quotas_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<GetQuotasInteractor>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  late MockGetQuotasInteractor getQuotasInteractor;
  late MockMailboxDashBoardController dashboard;
  late ActiveAccountBridge bridge;
  late Rxn<AccountId> personalAccountId;

  setUp(() {
    BaseControllerFixtures.registerDependencies();
    dashboard = MockMailboxDashBoardController();
    when(dashboard.sessionCurrent).thenReturn(DelegationFixtures.session());
    personalAccountId = Rxn<AccountId>(DelegationFixtures.aliceAccountId);
    when(dashboard.accountId).thenReturn(personalAccountId);
    Get.put<MailboxDashBoardController>(dashboard);
    bridge = ActiveAccountBridgeFixtures.put(DelegationFixtures.session());
    getQuotasInteractor = MockGetQuotasInteractor();
    when(getQuotasInteractor.execute(any)).thenAnswer((_) => const Stream.empty());
  });

  tearDown(Get.reset);

  test('loads the quota of the shown account, not of my own', () {
    bridge.accountId.value = DelegationFixtures.bobAccountId;

    QuotasController(getQuotasInteractor).reloadQuota();

    verify(getQuotasInteractor.execute(DelegationFixtures.bobAccountId)).called(1);
  });

  test('reloads the quota when another account is shown', () {
    QuotasController(getQuotasInteractor).onInit();

    bridge.accountId.value = DelegationFixtures.bobAccountId;

    verify(getQuotasInteractor.execute(DelegationFixtures.bobAccountId)).called(1);
  });

  test('loads the quota of a new dashboard that shows the account already shown before', () {
    personalAccountId.value = null;
    final controller = QuotasController(getQuotasInteractor)..onInit();

    bridge.applySession(DelegationFixtures.session());
    personalAccountId.value = DelegationFixtures.aliceAccountId;

    verify(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).called(1);
    controller.onClose();
  });

  test('a closed QuotasController no longer reloads the quota of a newly shown account', () {
    QuotasController(getQuotasInteractor)
      ..onInit()
      ..onClose();

    bridge.accountId.value = DelegationFixtures.bobAccountId;

    verifyNever(getQuotasInteractor.execute(DelegationFixtures.bobAccountId));
  });

  test('a quota still loading for the account shown before never replaces the quota of the shown account',
      () async {
    final myQuotaRequest = StreamController<Either<Failure, Success>>();
    addTearDown(myQuotaRequest.close);
    when(dashboard.octetsQuota).thenReturn(Rxn<Quota>());
    when(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).thenAnswer((_) => myQuotaRequest.stream);
    when(getQuotasInteractor.execute(DelegationFixtures.bobAccountId))
        .thenAnswer((_) => Stream.value(Right(GetQuotasSuccess([_storageQuota('bob-storage')]))));
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);

    bridge.accountId.value = DelegationFixtures.bobAccountId;
    await pumpEventQueue();
    myQuotaRequest.add(Right(GetQuotasSuccess([_storageQuota('alice-storage')])));
    await pumpEventQueue();

    expect(dashboard.octetsQuota.value?.id, Id('bob-storage'));
  });
}

Quota _storageQuota(String id) => Quota(Id(id), ResourceType.octets, Scope.account, 'Storage', used: UnsignedInt(1));

