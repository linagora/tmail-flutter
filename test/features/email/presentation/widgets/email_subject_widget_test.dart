import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_subject_widget.dart';

import '../../../../fixtures/widget_fixtures.dart';

void main() {
  group('EmailSubjectWidget', () {
    final imagePaths = ImagePaths();

    Widget makeTestableWidget({
      required String emailSubject,
      bool isMobileResponsive = false,
    }) {
      return WidgetFixtures.makeTestableWidget(
        child: EmailSubjectWidget(
          emailSubject: emailSubject,
          imagePaths: imagePaths,
          isMobileResponsive: isMobileResponsive,
        ),
      );
    }

    testWidgets(
      'should render nothing when subject is empty',
      (tester) async {
        await tester.pumpWidget(makeTestableWidget(emailSubject: ''));
        await tester.pumpAndSettle();

        expect(find.byType(SelectableText), findsNothing);
        expect(find.byType(Text), findsNothing);
      },
    );

    group('when platform is mobile', () {
      testWidgets(
        'should render SelectableText when isMobileResponsive is false',
        (tester) async {
          const subject = 'Meeting tomorrow';

          await tester.pumpWidget(makeTestableWidget(emailSubject: subject));
          await tester.pumpAndSettle();

          expect(find.byType(SelectableText), findsOneWidget);
          expect(find.text(subject), findsOneWidget);
        },
      );

      testWidgets(
        'should render SelectableText when isMobileResponsive is true',
        (tester) async {
          const subject = 'Important: Action required';

          await tester.pumpWidget(
            makeTestableWidget(emailSubject: subject, isMobileResponsive: true),
          );
          await tester.pumpAndSettle();

          expect(find.byType(SelectableText), findsOneWidget);
          expect(find.text(subject), findsOneWidget);
        },
      );
    });

    group('when platform is web', () {
      setUp(() => PlatformInfo.isTestingForWeb = true);
      tearDown(() => PlatformInfo.isTestingForWeb = false);

      testWidgets(
        'should render Text when subject is not empty',
        (tester) async {
          const subject = 'Meeting tomorrow';

          await tester.pumpWidget(makeTestableWidget(emailSubject: subject));
          await tester.pumpAndSettle();

          expect(find.byType(SelectableText), findsNothing);
          expect(find.text(subject), findsOneWidget);
        },
      );
    });
  });
}
