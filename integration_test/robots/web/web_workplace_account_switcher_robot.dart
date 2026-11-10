import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_workplace_account_switcher_assertion_robot.dart';
import '../abstract/abstract_workplace_account_switcher_robot.dart';
import 'web_workplace_account_switcher_assertion_robot.dart';

/// Web Workplace account-switcher chip (#4977 §8).
class WebWorkplaceAccountSwitcherRobot extends CoreRobot
    implements AbstractWorkplaceAccountSwitcherRobot {
  @override
  final AbstractWorkplaceAccountSwitcherAssertionRobot assertion;

  WebWorkplaceAccountSwitcherRobot(super.$)
      : assertion = WebWorkplaceAccountSwitcherAssertionRobot($);

  bool get _isMenuOpen =>
      $(LinagoraAccountSwitcher.menuKey).evaluate().isNotEmpty;

  ProviderContainer _appContainer() {
    final element = $.tester.element(find.byType(MaterialApp));
    return ProviderScope.containerOf(element, listen: false);
  }

  AccountId _accountIdForAddress(String emailAddress) {
    final session = _appContainer().read(activeAccountProvider)?.session;
    if (session == null) {
      throw StateError('no active session for workplace account switcher');
    }
    if (session.getOwnEmailAddressOrEmpty() == emailAddress) {
      return session.accountId;
    }
    for (final entry in session.delegatedAccounts) {
      if (entry.value.name.value == emailAddress) return entry.key;
    }
    throw StateError('no account listed for $emailAddress');
  }

  @override
  Future<void> openMenu() async {
    if (_isMenuOpen) return;
    await $(LinagoraAccountSwitcher.chipKey).tap();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> selectByAddress(String emailAddress) async {
    await openMenu();
    await selectAddressWhenMenuOpen(emailAddress);
  }

  @override
  Future<void> selectAddressWhenMenuOpen(String emailAddress) async {
    final itemKey = LinagoraAccountMenu.itemKey(_accountIdForAddress(emailAddress));
    await $(LinagoraAccountSwitcher.menuKey).$(itemKey).tap();
    await $.pumpAndTrySettle();
  }
}
