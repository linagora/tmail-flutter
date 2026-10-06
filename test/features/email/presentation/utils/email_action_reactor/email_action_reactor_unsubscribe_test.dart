import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class _FakeMarkAsEmailReadInteractor extends Fake
    implements MarkAsEmailReadInteractor {}

class _FakeMarkAsStarEmailInteractor extends Fake
    implements MarkAsStarEmailInteractor {}

class _FakePrintEmailInteractor extends Fake implements PrintEmailInteractor {}

class _FakeGetEmailContentInteractor extends Fake
    implements GetEmailContentInteractor {}

const _senderName = 'Emma';

EmailActionReactor _createReactor() => EmailActionReactor(
      _FakeMarkAsEmailReadInteractor(),
      _FakeMarkAsStarEmailInteractor(),
      null,
      _FakePrintEmailInteractor(),
      _FakeGetEmailContentInteractor(),
    );

Future<void> _openUnsubscribeDialog(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    GetMaterialApp(
      locale: locale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(body: SizedBox()),
    ),
  );
  await tester.pumpAndSettle();

  _createReactor().unsubscribeEmail(
    PresentationEmail(
      from: {EmailAddress(_senderName, 'emma@example.com')},
    ),
    emailUnsubscribe: null,
    onUnsubscribeByHttpsLink: (_) {},
    onUnsubscribeByMailtoLink: (_, __) {},
  );
  await tester.pumpAndSettle();
}

TextSpan _findDialogMessage(WidgetTester tester) {
  final richText = tester.widgetList<RichText>(find.byType(RichText)).firstWhere(
        (widget) => widget.text.toPlainText().contains(_senderName),
      );
  return richText.text as TextSpan;
}

List<TextSpan> _senderNameSpans(TextSpan message) {
  final spans = <TextSpan>[];
  message.visitChildren((span) {
    if (span is TextSpan && span.text == _senderName) spans.add(span);
    return true;
  });
  return spans;
}

Future<void> _expectDialogMessage(
  WidgetTester tester,
  Locale locale,
  String expectedMessage,
) async {
  await _openUnsubscribeDialog(tester, locale);

  final message = _findDialogMessage(tester);
  expect(message.toPlainText(), expectedMessage);

  final senderNameSpans = _senderNameSpans(message);
  expect(senderNameSpans, hasLength(1));
  expect(senderNameSpans.single.style?.fontWeight, FontWeight.w700);
}

void main() {
  setUp(() {
    Get.put(ResponsiveUtils(), permanent: true);
    Get.put(ImagePaths(), permanent: true);
  });

  tearDown(Get.reset);

  group('EmailActionReactor.unsubscribeEmail dialog message', () {
    testWidgets(
      'should put the question mark right after the bold sender name in English',
      (tester) => _expectDialogMessage(
        tester,
        const Locale('en', 'US'),
        'Are you sure you\'d like to stop receiving similar messages from Emma?',
      ),
    );

    testWidgets(
      'should put a narrow no-break space before the question mark in French',
      (tester) => _expectDialogMessage(
        tester,
        const Locale('fr', 'FR'),
        'Confirmez-vous ne plus vouloir recevoir de message similaire '
        'en provenance de Emma\u202F?',
      ),
    );

    testWidgets(
      'should place the bold sender name inside the sentence in German',
      (tester) => _expectDialogMessage(
        tester,
        const Locale('de', 'DE'),
        'Sind Sie sicher, dass Sie keine ähnlichen Nachrichten mehr '
        'von Emma erhalten möchten?',
      ),
    );
  });
}
