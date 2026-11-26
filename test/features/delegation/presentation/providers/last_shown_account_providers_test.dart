import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/last_shown_account_store_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/last_shown_account_store.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/last_shown_account_providers.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  final alice = UserName(DelegationFixtures.aliceAddress);
  late LastShownAccountStore store;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = LastShownAccountStoreImpl(await SharedPreferences.getInstance());
    container = ProviderContainer(
      overrides: [lastShownAccountStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
  });

  ActiveAccountNotifier startRecording() {
    final notifier = container.read(activeAccountProvider.notifier)
      ..applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    container.read(lastShownAccountRecorderProvider);
    return notifier;
  }

  test('writes a shown delegated account', () {
    startRecording().select(DelegationFixtures.bobAccountId);

    expect(store.read(alice), DelegationFixtures.bobAccountId);
  });

  test('removes the entry when mine is shown', () async {
    await store.save(alice, DelegationFixtures.bobAccountId);
    startRecording()
      ..select(DelegationFixtures.bobAccountId)
      ..selectPersonal();

    expect(store.read(alice), isNull);
  });

  test('removes the entry on sign-out', () {
    startRecording()
      ..select(DelegationFixtures.bobAccountId)
      ..clear();

    expect(store.read(alice), isNull);
  });

  test('removes the entry when a re-read session no longer lists the shown account', () {
    startRecording()
      ..select(DelegationFixtures.bobAccountId)
      ..applySession(DelegationFixtures.session(listsBob: false));

    expect(store.read(alice), isNull);
  });

  test('should not remove the entry on the session read of a start', () async {
    await store.save(alice, DelegationFixtures.bobAccountId);
    container.read(lastShownAccountRecorderProvider);

    container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());

    expect(store.read(alice), DelegationFixtures.bobAccountId);
  });

  test('should not touch the entry of another username', () async {
    final carol = UserName(DelegationFixtures.carolAddress);
    await store.save(carol, DelegationFixtures.bobAccountId);

    startRecording()
      ..select(DelegationFixtures.bobAccountId)
      ..selectPersonal();

    expect(store.read(carol), DelegationFixtures.bobAccountId);
  });
}
