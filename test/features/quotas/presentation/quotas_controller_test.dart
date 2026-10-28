import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/riverpod_active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';

import '../../../fixtures/active_account_source_fixtures.dart';
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
  late ProviderContainer container;
  late RiverpodActiveAccountSource source;
  late Rxn<Quota> octetsQuota;

  setUp(() {
    BaseControllerFixtures.registerDependencies();
    dashboard = MockMailboxDashBoardController();
    octetsQuota = Rxn<Quota>();
    when(dashboard.sessionCurrent).thenReturn(DelegationFixtures.session());
    when(dashboard.octetsQuota).thenReturn(octetsQuota);
    Get.put<MailboxDashBoardController>(dashboard);
    container = ActiveAccountSourceFixtures.newContainer();
    source = ActiveAccountSourceFixtures.put(DelegationFixtures.session(), container: container);
    getQuotasInteractor = MockGetQuotasInteractor();
    when(getQuotasInteractor.execute(any)).thenAnswer((_) => const Stream.empty());
  });

  tearDown(Get.reset);

  void show(AccountId accountId) => container.read(activeAccountProvider.notifier).select(accountId);

  test('loads the quota of the shown account, not of my own', () {
    show(DelegationFixtures.bobAccountId);

    QuotasController(getQuotasInteractor).reloadQuota();

    verify(getQuotasInteractor.execute(DelegationFixtures.bobAccountId)).called(1);
  });

  test('reloads the quota when another account is shown', () {
    QuotasController(getQuotasInteractor).onInit();

    show(DelegationFixtures.bobAccountId);

    verify(getQuotasInteractor.execute(DelegationFixtures.bobAccountId)).called(1);
  });

  test('loads the quota of the shown account at once when it starts', () {
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);

    verify(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).called(1);
  });

  test('does not load the quota before a new dashboard applies its session, then loads it once', () {
    source.clear();
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);
    verifyNever(getQuotasInteractor.execute(any));

    source.applySession(DelegationFixtures.session());

    verify(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).called(1);
  });

  test('does not reload the quota on a session re-read of the same account', () {
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);
    clearInteractions(getQuotasInteractor);

    source.applySession(DelegationFixtures.session(state: 'state-2'));

    verifyNever(getQuotasInteractor.execute(any));
  });

  test('a closed QuotasController no longer reloads the quota of a newly shown account', () {
    QuotasController(getQuotasInteractor)
      ..onInit()
      ..onClose();

    show(DelegationFixtures.bobAccountId);

    verifyNever(getQuotasInteractor.execute(DelegationFixtures.bobAccountId));
  });

  test('a quota still loading for the account shown before never replaces the quota of the shown account',
      () async {
    final myQuotaRequest = StreamController<Either<Failure, Success>>();
    addTearDown(myQuotaRequest.close);
    when(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).thenAnswer((_) => myQuotaRequest.stream);
    when(getQuotasInteractor.execute(DelegationFixtures.bobAccountId))
        .thenAnswer((_) => Stream.value(Right(GetQuotasSuccess([_storageQuota('bob-storage')]))));
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);

    show(DelegationFixtures.bobAccountId);
    await pumpEventQueue();
    myQuotaRequest.add(Right(GetQuotasSuccess([_storageQuota('alice-storage')])));
    await pumpEventQueue();

    expect(dashboard.octetsQuota.value?.id, Id('bob-storage'));
  });

  test('a quota arriving once a logout ended the session never reaches the view', () async {
    final myQuotaRequest = StreamController<Either<Failure, Success>>();
    addTearDown(myQuotaRequest.close);
    when(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).thenAnswer((_) => myQuotaRequest.stream);
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);

    container.read(accountSwitchProvider.notifier).endSession();
    myQuotaRequest.add(Right(GetQuotasSuccess([_storageQuota('alice-storage')])));
    await pumpEventQueue();

    expect(octetsQuota.value, isNull);
  });

  test('a new quota request drops the result of the one still running', () async {
    final firstRequest = StreamController<Either<Failure, Success>>();
    addTearDown(firstRequest.close);
    when(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId)).thenAnswer((_) => firstRequest.stream);
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);
    when(getQuotasInteractor.execute(DelegationFixtures.aliceAccountId))
        .thenAnswer((_) => Stream.value(Right(GetQuotasSuccess([_storageQuota('alice-storage-2')]))));

    controller.reloadQuota();
    await pumpEventQueue();
    firstRequest.add(Right(GetQuotasSuccess([_storageQuota('alice-storage-1')])));
    await pumpEventQueue();

    expect(octetsQuota.value?.id, Id('alice-storage-2'));
  });

  test('the quota of the account shown before is cleared while the new one loads', () {
    final controller = QuotasController(getQuotasInteractor)..onInit();
    addTearDown(controller.onClose);
    octetsQuota.value = _storageQuota('alice-storage');

    show(DelegationFixtures.bobAccountId);

    expect(octetsQuota.value, isNull);
  });

}

Quota _storageQuota(String id) => Quota(Id(id), ResourceType.octets, Scope.account, 'Storage', used: UnsignedInt(1));

