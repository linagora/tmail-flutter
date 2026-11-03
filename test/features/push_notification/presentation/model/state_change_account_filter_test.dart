import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:jmap_dart_client/jmap/push/type_state.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/model/state_change_account_filter.dart';

void main() {
  final mine = AccountId(Id('mine'));
  final owner = AccountId(Id('owner'));
  final other = AccountId(Id('other'));

  StateChange changeWith(Iterable<AccountId> accounts) => StateChange(
        'StateChange',
        {for (final id in accounts) id: TypeState({'Email': 's'})},
      );

  group('StateChangeAccountFilter with delegated entries dropped', () {
    final filter = StateChangeAccountFilter(
      personalAccountId: mine,
      activeAccountId: mine,
      delegatedAccountIds: {owner},
    );

    test('processes mine and drops a delegated account', () {
      expect(
        filter.accountsToProcess(changeWith([mine, owner, other])).toList(),
        [mine],
      );
    });

    test('refreshes the view and keeps delivery only for mine when active is mine', () {
      expect(filter.shouldRefreshView(mine), isTrue);
      expect(filter.shouldKeepDelivery(mine), isTrue);
      expect(filter.shouldStoreOfflineBodies(mine), isTrue);
      expect(filter.shouldRefreshView(owner), isFalse);
      expect(filter.shouldKeepDelivery(owner), isFalse);
      expect(filter.shouldStoreOfflineBodies(owner), isFalse);
    });
  });

  group('StateChangeAccountFilter while a delegated account is shown', () {
    final filter = StateChangeAccountFilter(
      personalAccountId: mine,
      activeAccountId: owner,
      delegatedAccountIds: {owner},
    );

    test('processes mine for delivery and the active account for the view', () {
      expect(
        filter.accountsToProcess(changeWith([mine, owner])).toList(),
        containsAll([mine, owner]),
      );
      expect(filter.shouldRefreshView(owner), isTrue);
      expect(filter.shouldRefreshView(mine), isFalse);
      expect(filter.shouldKeepDelivery(mine), isTrue);
      expect(filter.shouldKeepDelivery(owner), isFalse);
      expect(filter.shouldStoreOfflineBodies(owner), isFalse);
      expect(filter.shouldStoreOfflineBodies(mine), isTrue);
    });

    test('skips the active account while a switch runs', () {
      final switching = StateChangeAccountFilter(
        personalAccountId: mine,
        activeAccountId: owner,
        isSwitching: true,
        delegatedAccountIds: {owner},
      );

      expect(
        switching.accountsToProcess(changeWith([mine, owner])).toList(),
        [mine],
      );
      expect(switching.shouldRefreshView(owner), isFalse);
    });
  });

  group('StateChangeAccountFilter with includeDelegated', () {
    test('keeps delivery for a listed delegated account', () {
      final filter = StateChangeAccountFilter(
        personalAccountId: mine,
        activeAccountId: mine,
        delegatedAccountIds: {owner},
        includeDelegated: true,
      );

      expect(filter.shouldProcess(owner), isTrue);
      expect(filter.shouldKeepDelivery(owner), isTrue);
      expect(filter.shouldRefreshView(owner), isFalse);
      expect(filter.shouldStoreOfflineBodies(owner), isFalse);
    });
  });
}
