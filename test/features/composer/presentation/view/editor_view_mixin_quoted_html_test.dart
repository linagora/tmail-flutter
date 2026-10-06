import 'package:core/presentation/extensions/html_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/editor_view_mixin.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class _QuoteHarness with EditorViewMixin {}

void main() {
  Future<AppLocalizations> pumpLocalizations(WidgetTester tester) async {
    late AppLocalizations localizations;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: LocalizationService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            localizations = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return localizations;
  }

  testWidgets('quote wrap adds cite, blockquote and editor start tags', (
    tester,
  ) async {
    final localizations = await pumpLocalizations(tester);
    final html = _QuoteHarness().getEmailContentQuotedAsHtml(
      locale: const Locale('en'),
      appLocalizations: localizations,
      emailContent: '<p>Previous</p>',
      emailActionType: EmailActionType.reply,
      presentationEmail: PresentationEmail(
        from: {EmailAddress('Alice', 'alice@example.com')},
      ),
    );

    expect(html, startsWith(HtmlExtension.editorStartTags));
    expect(html, contains('<cite'));
    expect(html, contains('<blockquote'));
    expect(html, contains('<p>Previous</p>'));
  });

  testWidgets('quote wrap escapes HTML in the from name', (tester) async {
    final localizations = await pumpLocalizations(tester);
    final html = _QuoteHarness().getEmailContentQuotedAsHtml(
      locale: const Locale('en'),
      appLocalizations: localizations,
      emailContent: '<p>Body</p>',
      emailActionType: EmailActionType.reply,
      presentationEmail: PresentationEmail(
        from: {EmailAddress('Alice <img src=x onerror=alert(1)>', 'alice@example.com')},
      ),
    );

    expect(html, isNot(contains('<img src=x onerror=alert(1)>')));
    expect(html, contains('&lt;'));
  });

  testWidgets('forward wrap escapes HTML in the subject', (tester) async {
    final localizations = await pumpLocalizations(tester);
    final html = _QuoteHarness().getEmailContentQuotedAsHtml(
      locale: const Locale('en'),
      appLocalizations: localizations,
      emailContent: '<p>Body</p>',
      emailActionType: EmailActionType.forward,
      presentationEmail: PresentationEmail(
        subject: '<script>alert(1)</script>',
        from: {EmailAddress('Alice', 'alice@example.com')},
      ),
    );

    expect(html, isNot(contains('<script>alert(1)</script>')));
    expect(html, contains('&lt;script&gt;'));
  });
}
