import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/information_sender_and_receiver_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  group('InformationSenderAndReceiverBuilder::widgetTest', () {
    final responsiveUtils = ResponsiveUtils();
    final imagePaths = ImagePaths();

    Widget makeTestableWidget({required Widget child}) {
      return GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Scaffold(body: child),
      );
    }

    group('SMimeSignatureStatusIcon::test', () {
      testWidgets('should be displayed when email header has X-SMIME-Status', (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          },
          emailHeader: [
            EmailHeader(EmailProperty.headerSMimeStatusKey, 'Good signature')
          ]
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsOneWidget);
      });

      testWidgets(
        'should be displayed and have good message \n'
        'when email header has X-SMIME-Status = "Good signature"',
      (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          },
          emailHeader: [
            EmailHeader(EmailProperty.headerSMimeStatusKey, 'Good signature')
          ]
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsOneWidget);

        final sMimeSignatureStatusIconWidgetFinder = find.byKey(const Key('smime_signature_status_icon'));
        final sMimeSignatureStatusIconWidget = tester.widget<Tooltip>(sMimeSignatureStatusIconWidgetFinder);
        expect(
          sMimeSignatureStatusIconWidget.message,
          'The authenticity of this message had been verified with SMime signature.');
      });

      testWidgets(
        'should be displayed and have bad message \n'
        'when email header has X-SMIME-Status = "Bad signature"',
      (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          },
          emailHeader: [
            EmailHeader(EmailProperty.headerSMimeStatusKey, 'Bad signature')
          ]
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsOneWidget);

        final sMimeSignatureStatusIconWidgetFinder = find.byKey(const Key('smime_signature_status_icon'));
        final sMimeSignatureStatusIconWidget = tester.widget<Tooltip>(sMimeSignatureStatusIconWidgetFinder);
        expect(
          sMimeSignatureStatusIconWidget.message,
          'This message failed SMime signature verification.');
      });

      testWidgets('should not be displayed when email header do not have X-SMIME-Status', (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          }
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsNothing);
      });

      testWidgets('should not be displayed when email header have X-SMIME-Status = "Good Signatures"', (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          },
          emailHeader: [
            EmailHeader(EmailProperty.headerSMimeStatusKey, 'Good Signatures')
          ]
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsNothing);
      });

      testWidgets('should not be displayed when email header have X-SMIME-Status = "Good signatures"', (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          },
          emailHeader: [
            EmailHeader(EmailProperty.headerSMimeStatusKey, 'Good signatures')
          ]
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsNothing);
      });

      testWidgets('should not be displayed when email header have X-SMIME-Status = "Bad Signatures"', (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          },
          emailHeader: [
            EmailHeader(EmailProperty.headerSMimeStatusKey, 'Bad Signatures')
          ]
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsNothing);
      });

      testWidgets('should not be displayed when email header have X-SMIME-Status = "Bad signatures"', (tester) async {
        final presentationEmail = PresentationEmail(
          id: EmailId(Id('a123')),
          from: {
            EmailAddress('example', 'example@linagora.com')
          },
          emailHeader: [
            EmailHeader(EmailProperty.headerSMimeStatusKey, 'Bad signatures')
          ]
        );
        final widget = makeTestableWidget(
          child: InformationSenderAndReceiverBuilder(
            emailSelected: presentationEmail,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            emailUnsubscribe: null,
          ),
        );

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('smime_signature_status_icon')),
          findsNothing);
      });
    });
  });
}