import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_capabilities_provider.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  final recipient = EmailAddress('Recipient', 'recipient@example.com');

  Future<void> openRecipientMenu(
    WidgetTester tester, {
    required ActiveAccount? shownAccount,
    OnEditRecipientAction? onEditRecipientAction,
  }) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        shownAccountCapabilitiesProvider.overrideWithValue(ShownAccountCapabilities.of(shownAccount)),
      ],
      child: GetMaterialApp(
        locale: LocalizationService.defaultLocale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        // The menu opens in the app overlay, which needs a Material above the navigator.
        builder: (_, child) => Material(child: child),
        home: Scaffold(
          body: Center(
            child: RecipientTagItemWidget(
              index: 0,
              prefix: PrefixEmailAddress.to,
              currentEmailAddress: recipient,
              currentListEmailAddress: [recipient],
              imagePaths: ImagePaths(),
              onEditRecipientAction: onEditRecipientAction,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('label_recipient_tag_item_to_0')));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  testWidgets('the recipient menu offers create a rule while my own account is shown', (tester) async {
    await openRecipientMenu(tester, shownAccount: null);

    expect(find.text('Create a rule'), findsOneWidget);
  });

  testWidgets('the recipient menu does not offer create a rule while a delegated account is shown', (tester) async {
    await openRecipientMenu(
      tester,
      shownAccount: ActiveAccount.delegated(DelegationFixtures.session(), DelegationFixtures.bobAccountId),
    );

    expect(find.text('Edit email'), findsOneWidget);
    expect(find.text('Create a rule'), findsNothing);
  });

  testWidgets('choosing create a rule closes the recipient menu and asks to create a rule for that recipient', (tester) async {
    final actions = <EmailAddressActionType>[];
    await openRecipientMenu(
      tester,
      shownAccount: null,
      onEditRecipientAction: (_, prefix, emailAddress, actionType) {
        expect(prefix, PrefixEmailAddress.to);
        expect(emailAddress, recipient);
        actions.add(actionType);
      },
    );

    await tester.tap(find.text('Create a rule'));
    await tester.pumpAndSettle();

    expect(actions, [EmailAddressActionType.createRule]);
    expect(find.text('Create a rule'), findsNothing);
  });
}
