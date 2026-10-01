import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

const _french = Locale('fr', 'FR');
const _english = Locale('en', 'US');

final _sender = EmailAddress('Test BTELLIER', 'btellier@example.com');

final _email = PresentationEmail(
  subject: 'Hello',
  receivedAt: UTCDate(DateTime(2026, 9, 25, 15, 56).toUtc()),
  from: {_sender},
);

Future<BuildContext> _pumpLocalizedWidget(
  WidgetTester tester,
  Locale locale,
) async {
  late BuildContext context;

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (ctx) {
          context = ctx;
          return const SizedBox();
        },
      ),
    ),
  );

  await tester.pumpAndSettle();

  return context;
}

Future<String?> _headerFor(
  WidgetTester tester,
  Locale locale,
  EmailActionType actionType, {
  PresentationEmail? presentationEmail,
}) async {
  final context = await _pumpLocalizedWidget(tester, locale);
  return actionType.getHeaderEmailQuoted(
    locale: Localizations.localeOf(context),
    appLocalizations: AppLocalizations.of(context),
    presentationEmail: presentationEmail ?? _email,
  );
}

void _replyTests() {
  testWidgets('reply uses the localized date and "a écrit" in fr',
      (tester) async {
    final header = await _headerFor(tester, _french, EmailActionType.reply);

    expect(
      header,
      'Le 25 sept. 2026 à 15:56, '
      'Test BTELLIER &lt;btellier@example.com&gt; a écrit :',
    );
  });

  testWidgets('reply uses the localized date and "wrote" in en',
      (tester) async {
    final header = await _headerFor(tester, _english, EmailActionType.reply);

    expect(
      header,
      'On Sep 25, 2026 at 3:56 PM, '
      'Test BTELLIER &lt;btellier@example.com&gt; wrote:',
    );
  });

  testWidgets('reply leaves the date empty when receivedAt is null',
      (tester) async {
    final header = await _headerFor(
      tester,
      _english,
      EmailActionType.reply,
      presentationEmail: PresentationEmail(from: {_sender}),
    );

    expect(
      header,
      'On , Test BTELLIER &lt;btellier@example.com&gt; wrote:',
    );
  });
}

void _dateTimeJoinerTests() {
  testWidgets('reply uses the localized date and time joiner in de',
      (tester) async {
    final header = await _headerFor(
      tester,
      const Locale('de', 'DE'),
      EmailActionType.reply,
    );

    expect(
      header,
      'Am 25. Sept. 2026 um 15:56, '
      'von Test BTELLIER &lt;btellier@example.com&gt;',
    );
  });

  for (final locale in LocalizationService.supportedLocales
      .where((locale) => locale.languageCode != 'en')) {
    testWidgets('reply does not use the English "at" joiner in $locale',
        (tester) async {
      final header = await _headerFor(tester, locale, EmailActionType.reply);

      expect(header, isNot(contains(' at ')));
    });
  }
}

void _forwardTests() {
  testWidgets('forward uses the localized date in fr', (tester) async {
    final header = await _headerFor(tester, _french, EmailActionType.forward);

    expect(
      header,
      '------- Message transféré -------</br>'
      'Sujet: Hello</br>'
      'Date: 25 sept. 2026 à 15:56</br>'
      'De: Test BTELLIER &lt;btellier@example.com&gt;</br>',
    );
  });

  testWidgets('forward uses the localized date in en', (tester) async {
    final header = await _headerFor(tester, _english, EmailActionType.forward);

    expect(
      header,
      '------- Forwarded message -------</br>'
      'Subject: Hello</br>'
      'Date: Sep 25, 2026 at 3:56 PM</br>'
      'From: Test BTELLIER &lt;btellier@example.com&gt;</br>',
    );
  });
}

void main() {
  group('EmailActionTypeExtension.getHeaderEmailQuoted', () {
    _replyTests();
    _dateTimeJoinerTests();
    _forwardTests();
  });
}
