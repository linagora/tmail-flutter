import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_sections.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() {
    l10n = AppLocalizations();
  });

  Widget avatar(String email) => Text(email);

  group('buildAccountSwitcherSections', () {
    test('puts my mailbox first and every delegated account under Delegated to you', () {
      final sections = buildAccountSwitcherSections(
        session: DelegationFixtures.session(),
        l10n: l10n,
        avatarFor: avatar,
      );

      expect(sections, hasLength(2));
      expect(sections[0].title, l10n.yourMailbox);
      expect(sections[0].items.single.id, DelegationFixtures.aliceAccountId);
      expect(sections[0].items.single.name, DelegationFixtures.aliceAddress);

      expect(sections[1].title, l10n.delegatedToYou);
      expect(
        sections[1].items.map((item) => item.id),
        [DelegationFixtures.bobAccountId, DelegationFixtures.carolAccountId],
      );
      expect(
        sections[1].items.map((item) => item.name),
        [DelegationFixtures.bobAddress, DelegationFixtures.carolAddress],
      );
    });

    test('omits the delegated section items when the session lists none', () {
      final sections = buildAccountSwitcherSections(
        session: DelegationFixtures.session(listsBob: false, listsCarol: false),
        l10n: l10n,
        avatarFor: avatar,
      );

      expect(sections[1].items, isEmpty);
    });
  });
}
