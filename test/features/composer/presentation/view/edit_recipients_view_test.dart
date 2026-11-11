import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/edit_recipients_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  final emailAddress = EmailAddress('Recipient', 'recipient@example.com');

  Future<void> pumpMenu(WidgetTester tester, {required bool isMobile, VoidCallback? onCreateRuleAction}) =>
      tester.pumpWidget(GetMaterialApp(
        locale: LocalizationService.defaultLocale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        home: Scaffold(
          body: EditRecipientsView(
            emailAddress: emailAddress,
            imagePaths: ImagePaths(),
            isMobile: isMobile,
            width: 361,
            onCopyAction: () {},
            onEditAction: () {},
            onCreateRuleAction: onCreateRuleAction,
            onCloseAction: () {},
          ),
        ),
      ));

  for (final isMobile in [true, false]) {
    final layout = isMobile ? 'mobile' : 'desktop';
    final editLabel = isMobile ? 'Edit' : 'Edit email';

    testWidgets('$layout menu offers create a rule and runs it when an action is given', (tester) async {
      var created = 0;
      await pumpMenu(tester, isMobile: isMobile, onCreateRuleAction: () => created++);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create a rule'));
      await tester.pump();

      expect(created, 1);
    });

    testWidgets('$layout menu does not offer create a rule when no action is given', (tester) async {
      await pumpMenu(tester, isMobile: isMobile);
      await tester.pumpAndSettle();

      expect(find.text('Create a rule'), findsNothing);
      expect(find.text(editLabel), findsOneWidget);
    });
  }
}
