import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/widget/labels/ai_action_tag_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../../fixtures/widget_fixtures.dart';

void main() {
  setUpAll(() {
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
  });

  group('EmailTileBuilder – AI Action tag display', () {
    final emailWithNeedsAction = PresentationEmail(
      id: EmailId(Id('email-needs-action')),
      subject: 'Email needs-action',
      keywords: {
        KeyWordIdentifierExtension.needsActionMail: true,
      },
    );

    final emailWithoutNeedsAction = PresentationEmail(
      id: EmailId(Id('email-normal')),
      subject: 'Email normal',
    );

    group('when AI needs action enabled', () {
      testWidgets('shows AI Action tag on mobile', (tester) async {
        await WidgetFixtures.pumpResponsiveWidget(
          tester,
          WidgetFixtures.makeTestableWidget(
            child: EmailTileBuilder(
              presentationEmail: emailWithNeedsAction,
              selectAllMode: SelectMode.INACTIVE,
              isShowingEmailContent: false,
              isAINeedsActionEnabled: true,
            ),
          ),
          logicalSize: const Size(375, 812),
        );

        expect(find.byType(AiActionTagWidget), findsOneWidget);

        WidgetFixtures.resetResponsive(tester);
      });

      testWidgets('shows AI Action tag on tablet', (tester) async {
        await WidgetFixtures.pumpResponsiveWidget(
          tester,
          WidgetFixtures.makeTestableWidget(
            child: EmailTileBuilder(
              presentationEmail: emailWithNeedsAction,
              selectAllMode: SelectMode.INACTIVE,
              isShowingEmailContent: false,
              isAINeedsActionEnabled: true,
            ),
          ),
          logicalSize: const Size(1024, 1366),
        );

        expect(find.byType(AiActionTagWidget), findsOneWidget);

        WidgetFixtures.resetResponsive(tester);
      });

      testWidgets('shows AI Action tag on desktop', (tester) async {
        await WidgetFixtures.pumpResponsiveWidget(
          tester,
          WidgetFixtures.makeTestableWidget(
            child: EmailTileBuilder(
              presentationEmail: emailWithNeedsAction,
              selectAllMode: SelectMode.INACTIVE,
              isShowingEmailContent: false,
              isAINeedsActionEnabled: true,
            ),
          ),
          logicalSize: const Size(1920, 1080),
          platform: TargetPlatform.macOS,
        );

        expect(find.byType(AiActionTagWidget), findsOneWidget);

        WidgetFixtures.resetResponsive(tester);
      });

      testWidgets(
        'does not show AI Action tag when email has no needs-action keyword',
        (tester) async {
          await WidgetFixtures.pumpResponsiveWidget(
            tester,
            WidgetFixtures.makeTestableWidget(
              child: EmailTileBuilder(
                presentationEmail: emailWithoutNeedsAction,
                selectAllMode: SelectMode.INACTIVE,
                isShowingEmailContent: false,
                isAINeedsActionEnabled: true,
              ),
            ),
            logicalSize: const Size(375, 812),
          );

          expect(find.byType(AiActionTagWidget), findsNothing);

          WidgetFixtures.resetResponsive(tester);
        },
      );

      testWidgets(
        'shows localized actionRequired text',
        (tester) async {
          await WidgetFixtures.pumpResponsiveWidget(
            tester,
            WidgetFixtures.makeTestableWidget(
              child: EmailTileBuilder(
                presentationEmail: emailWithNeedsAction,
                selectAllMode: SelectMode.INACTIVE,
                isShowingEmailContent: false,
                isAINeedsActionEnabled: true,
              ),
            ),
            logicalSize: const Size(375, 812),
          );

          final context = tester.element(find.byType(EmailTileBuilder));
          final expectedText = AppLocalizations.of(context).actionRequired;

          expect(find.text(expectedText), findsOneWidget);

          WidgetFixtures.resetResponsive(tester);
        },
      );
    });

    group('when AI needs action disabled', () {
      testWidgets(
        'does not show AI Action tag',
        (tester) async {
          await WidgetFixtures.pumpResponsiveWidget(
            tester,
            WidgetFixtures.makeTestableWidget(
              child: EmailTileBuilder(
                presentationEmail: emailWithNeedsAction,
                selectAllMode: SelectMode.INACTIVE,
                isShowingEmailContent: false,
                isAINeedsActionEnabled: false,
              ),
            ),
            logicalSize: const Size(375, 812),
          );

          expect(find.byType(AiActionTagWidget), findsNothing);

          WidgetFixtures.resetResponsive(tester);
        },
      );
    });
  });

  tearDownAll(() {
    Get.delete<ResponsiveUtils>();
    Get.delete<ImagePaths>();
  });
}
