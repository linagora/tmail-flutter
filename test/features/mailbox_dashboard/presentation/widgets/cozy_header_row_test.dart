import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/cozy_header_row.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  const rowWidth = 700.0;
  const searchWidth = 280.0;
  const trailingWidth = 40.0;
  const searchKey = ValueKey('search');
  const trailingKey = ValueKey('trailing');

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Future<void> pumpRow(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.defaultLocale,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: rowWidth,
                child: CozyHeaderRow(
                  search: SizedBox(key: searchKey, width: searchWidth, height: 44),
                  trailing: SizedBox(key: trailingKey, width: trailingWidth, height: 44),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder switcherSlot() => find.ancestor(
        of: find.byKey(LinagoraAccountSwitcher.chipKey),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Align &&
              widget.alignment == AlignmentDirectional.centerEnd,
        ),
      );

  group('CozyHeaderRow', () {
    testWidgets(
        'gives the account switcher all the room between search and trailing',
        (tester) async {
      DelegationFixtures.turnDelegationOn(container);
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpRow(tester);

      expect(
        tester.getSize(switcherSlot().first).width,
        rowWidth - searchWidth - trailingWidth,
      );
      expect(
        tester.getTopRight(find.byKey(LinagoraAccountSwitcher.chipKey)).dx,
        lessThanOrEqualTo(tester.getTopLeft(find.byKey(trailingKey)).dx),
      );
    });

    testWidgets('keeps trailing at the end when the switcher is hidden',
        (tester) async {
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpRow(tester);

      expect(find.byKey(LinagoraAccountSwitcher.chipKey), findsNothing);
      expect(tester.getTopLeft(find.byKey(searchKey)).dx, 0);
      expect(
        tester.getTopRight(find.byKey(trailingKey)).dx,
        rowWidth,
      );
    });
  });
}
