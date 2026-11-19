import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/delegated_notification_baseline_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/riverpod_widgets/mailbox_dashboard_provider_listener_widget.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notifier/fcm_bindings_registration_notifier.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late List<Map<AccountId, String>> stored;

  setUp(() {
    stored = [];
  });

  final mobile = TargetPlatformVariant.only(TargetPlatform.android);

  Future<ProviderContainer> pumpDelegate(
    WidgetTester tester, {
    StoreDelegatedNotificationBaselines? store,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MailboxDashboardProviderListenerWidget(
            delegateFactories: [
              () => DelegatedNotificationBaselineProviderListenerDelegate(
                    store: store ??
                        (Session session, Map<AccountId, String> ownerNames) async {
                          stored.add(ownerNames);
                          return true;
                        },
                  ),
            ],
            child: const SizedBox(),
          ),
        ),
      ),
    );
    return ProviderScope.containerOf(tester.element(find.byType(SizedBox)));
  }

  Future<void> show(WidgetTester tester, ProviderContainer container, Session session) async {
    container.read(activeAccountProvider.notifier).applySession(session);
    await tester.pump();
  }

  Future<void> setDelegation(WidgetTester tester, ProviderContainer container, bool isEnabled) async {
    container
        .read(localSettingsProvider.notifier)
        .update(PreferencesSetting([DelegationConfig(isEnabled: isEnabled)]));
    await tester.pump();
  }

  final bobAndCarol = {
    DelegationFixtures.bobAccountId: DelegationFixtures.bobAddress,
    DelegationFixtures.carolAccountId: DelegationFixtures.carolAddress,
  };

  testWidgets('stores the delegated owners once delegation is turned on', (tester) async {
    final container = await pumpDelegate(tester);
    await show(tester, container, DelegationFixtures.session());
    await setDelegation(tester, container, true);

    expect(stored.last, bobAndCarol);
  }, variant: mobile);

  testWidgets('SHOULD NOT store again when a re-read lists the same accounts', (tester) async {
    final container = await pumpDelegate(tester);
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());
    final storedCount = stored.length;

    await show(tester, container, DelegationFixtures.session(state: 'state-2'));

    expect(stored, hasLength(storedCount));
  }, variant: mobile);

  testWidgets('stores the new list when an account is no longer listed', (tester) async {
    final container = await pumpDelegate(tester);
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());

    await show(tester, container, DelegationFixtures.session(listsCarol: false));

    expect(stored.last, {DelegationFixtures.bobAccountId: DelegationFixtures.bobAddress});
  }, variant: mobile);

  testWidgets('stores an empty list when delegation is turned off', (tester) async {
    final container = await pumpDelegate(tester);
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());

    await setDelegation(tester, container, false);

    expect(stored.last, isEmpty);
  }, variant: mobile);

  testWidgets('a store started later SHOULD NOT finish before a slower earlier one', (tester) async {
    final firstStore = Completer<void>();
    final finished = <Map<AccountId, String>>[];
    final container = await pumpDelegate(tester, store: (Session session, Map<AccountId, String> ownerNames) async {
      if (ownerNames.isNotEmpty) await firstStore.future;
      finished.add(ownerNames);
      return true;
    });
    await show(tester, container, DelegationFixtures.session());
    await setDelegation(tester, container, true);

    await setDelegation(tester, container, false);
    firstStore.complete();
    await tester.pump();

    expect(finished, [<AccountId, String>{}, bobAndCarol, <AccountId, String>{}]);
  }, variant: mobile);

  testWidgets('keeps storing after a store fails', (tester) async {
    final container = await pumpDelegate(tester, store: (Session session, Map<AccountId, String> ownerNames) async {
      if (ownerNames.isNotEmpty) throw Exception('keychain locked');
      stored.add(ownerNames);
      return true;
    });
    await show(tester, container, DelegationFixtures.session());
    await setDelegation(tester, container, true);

    await setDelegation(tester, container, false);

    expect(stored, [<AccountId, String>{}, <AccountId, String>{}]);
  }, variant: mobile);

  testWidgets('retries the same accounts once the FCM interactors are bound', (tester) async {
    var bound = false;
    final container = await pumpDelegate(
      tester,
      store: (Session session, Map<AccountId, String> ownerNames) async {
        if (bound) stored.add(ownerNames);
        return bound;
      },
    );
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());
    expect(stored, isEmpty);

    bound = true;
    container.read(fcmBindingsRegistrationProvider.notifier).registered();
    await tester.pump();
    await show(tester, container, DelegationFixtures.session(state: 'state-2'));

    expect(stored, [bobAndCarol]);
  }, variant: mobile);

  testWidgets('stores the same accounts again on the next re-read after a failed store', (tester) async {
    var failed = false;
    final container = await pumpDelegate(tester, store: (Session session, Map<AccountId, String> ownerNames) async {
      if (ownerNames.isNotEmpty && !failed) {
        failed = true;
        return false;
      }
      stored.add(ownerNames);
      return true;
    });
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());

    await show(tester, container, DelegationFixtures.session(state: 'state-2'));

    expect(stored, [bobAndCarol]);
  }, variant: mobile);

  testWidgets('stores the same accounts again on the next re-read after a store throws', (tester) async {
    var thrown = false;
    final container = await pumpDelegate(tester, store: (Session session, Map<AccountId, String> ownerNames) async {
      if (ownerNames.isNotEmpty && !thrown) {
        thrown = true;
        throw Exception('keychain locked');
      }
      stored.add(ownerNames);
      return true;
    });
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());

    await show(tester, container, DelegationFixtures.session(state: 'state-2'));

    expect(stored, [bobAndCarol]);
  }, variant: mobile);

  testWidgets('stores the same accounts again when the FCM interactors are bound later', (tester) async {
    final container = await pumpDelegate(tester);
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());

    container.read(fcmBindingsRegistrationProvider.notifier).registered();
    await tester.pump();

    expect(stored, [bobAndCarol, bobAndCarol]);
  }, variant: mobile);

  testWidgets('SHOULD NOT store anything outside mobile', (tester) async {
    final container = await pumpDelegate(tester);
    await setDelegation(tester, container, true);
    await show(tester, container, DelegationFixtures.session());

    expect(stored, isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
