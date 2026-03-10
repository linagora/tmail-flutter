import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  Future<BuildContext> pumpLocalizedWidget(
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

  group('EmailActionTypeExtension.getSubjectComposer', () {
    const subject = 'Hello world';

    group('reply actions', () {
      test('should add default Re prefix when context is null', () {
        final result = EmailActionType.reply.getSubjectComposer(null, subject);

        expect(result, 'Re: Hello world');
      });

      test('should not duplicate Re prefix', () {
        const subjectWithPrefix = 'Re: Hello world';

        final result =
            EmailActionType.reply.getSubjectComposer(null, subjectWithPrefix);

        expect(result, subjectWithPrefix);
      });

      test('should ignore case when checking prefix', () {
        const subjectWithPrefix = 're: Hello world';

        final result =
            EmailActionType.reply.getSubjectComposer(null, subjectWithPrefix);

        expect(result, subjectWithPrefix);
      });

      test('Reply: does not dedupe legacy French NBSP prefix', () {
        const original = 'Re\u00A0: Legacy subject';
        final result = EmailActionType.reply.getSubjectComposer(null, original);
        expect(result, 'Re: $original');
      });

      test('Forward: does not dedupe legacy French NBSP prefix', () {
        const original = 'Tr\u00A0: Legacy subject';
        final result =
            EmailActionType.forward.getSubjectComposer(null, original);
        expect(result, 'Fwd: $original');
      });
    });

    group('forward actions', () {
      test('should add default Fwd prefix when context is null', () {
        final result =
            EmailActionType.forward.getSubjectComposer(null, subject);

        expect(result, 'Fwd: Hello world');
      });

      test('should not duplicate Fwd prefix', () {
        const subjectWithPrefix = 'Fwd: Hello world';

        final result =
            EmailActionType.forward.getSubjectComposer(null, subjectWithPrefix);

        expect(result, subjectWithPrefix);
      });

      test('should ignore case when checking prefix', () {
        const subjectWithPrefix = 'fwd: Hello world';

        final result =
            EmailActionType.forward.getSubjectComposer(null, subjectWithPrefix);

        expect(result, subjectWithPrefix);
      });
    });

    group('edit actions', () {
      test('editDraft should return original subject', () {
        final result =
            EmailActionType.editDraft.getSubjectComposer(null, subject);

        expect(result, subject);
      });

      test('editSendingEmail should return original subject', () {
        final result =
            EmailActionType.editSendingEmail.getSubjectComposer(null, subject);

        expect(result, subject);
      });

      test('editAsNewEmail should return original subject', () {
        final result =
            EmailActionType.editAsNewEmail.getSubjectComposer(null, subject);

        expect(result, subject);
      });
    });

    group('default case', () {
      test('should return empty string for unsupported action', () {
        final result =
            EmailActionType.markAsRead.getSubjectComposer(null, subject);

        expect(result, '');
      });
    });

    group('localized prefix', () {
      testWidgets('should use localized reply prefix (vi)', (tester) async {
        final context = await pumpLocalizedWidget(
          tester,
          const Locale('vi'),
        );

        const subject = 'Hello world';

        final result =
            EmailActionType.reply.getSubjectComposer(context, subject);

        final prefix = AppLocalizations.of(context).prefix_reply_email;

        expect(result, '$prefix Hello world');
      });

      testWidgets('should not duplicate localized reply prefix',
          (tester) async {
        final context = await pumpLocalizedWidget(
          tester,
          const Locale('vi'),
        );

        final prefix = AppLocalizations.of(context).prefix_reply_email;

        final subject = '$prefix Hello world';

        final result =
            EmailActionType.reply.getSubjectComposer(context, subject);

        expect(result, subject);
      });

      testWidgets('should use localized forward prefix', (tester) async {
        final context = await pumpLocalizedWidget(
          tester,
          const Locale('fr'),
        );

        const subject = 'Hello world';

        final result =
            EmailActionType.forward.getSubjectComposer(context, subject);

        final prefix = AppLocalizations.of(context).prefix_forward_email;

        expect(result, '$prefix Hello world');
      });

      testWidgets('should not duplicate localized forward prefix',
          (tester) async {
        final context = await pumpLocalizedWidget(
          tester,
          const Locale('fr'),
        );

        final prefix = AppLocalizations.of(context).prefix_forward_email;

        final subject = '$prefix Hello world';

        final result =
            EmailActionType.forward.getSubjectComposer(context, subject);

        expect(result, subject);
      });

      for (final locale in LocalizationService.supportedLocales) {
        testWidgets('reply prefix works for $locale', (tester) async {
          final context = await pumpLocalizedWidget(tester, locale);

          final result =
              EmailActionType.reply.getSubjectComposer(context, 'Hello');

          final prefix = AppLocalizations.of(context).prefix_reply_email;

          expect(result, '$prefix Hello');
        });
      }
    });
  });
}
