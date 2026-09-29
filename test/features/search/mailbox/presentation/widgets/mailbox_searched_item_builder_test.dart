import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/widgets/mailbox_searched_item_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  final teamMailboxRoot = PresentationMailbox(
    MailboxId(Id('team-root')),
    name: MailboxName('team'),
    namespace: Namespace('TeamMailbox[team@example.com]'),
    isSubscribed: IsSubscribed(true),
  );
  final sharedTopLevelFolder = PresentationMailbox(
    MailboxId(Id('shared-folder')),
    name: MailboxName('shared'),
    namespace: Namespace('Delegated[bob@example.com]'),
    isSubscribed: IsSubscribed(true),
  );

  setUp(() {
    Get.put(ImagePaths());
    Get.put(ResponsiveUtils());
    PlatformInfo.isTestingForWeb = true;
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
    Get.reset();
  });

  Future<PresentationMailbox?> tapSearchedMailbox(
    WidgetTester tester,
    PresentationMailbox mailbox,
  ) async {
    PresentationMailbox? openedMailbox;
    await _pump(
      tester,
      MailboxSearchedItemBuilder(
        presentationMailbox: mailbox,
        onClickOpenMailboxAction: (mailbox) => openedMailbox = mailbox,
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();

    return openedMailbox;
  }

  group('MailboxSearchedItemBuilder', () {
    testWidgets('does not open a team mailbox root on tap', (tester) async {
      expect(await tapSearchedMailbox(tester, teamMailboxRoot), isNull);
    });

    testWidgets('opens a top-level folder shared through ACL on tap',
        (tester) async {
      expect(
        await tapSearchedMailbox(tester, sharedTopLevelFolder),
        same(sharedTopLevelFolder),
      );
    });

    testWidgets('does not offer a team mailbox root as drop target',
        (tester) async {
      await _pump(
        tester,
        MailboxSearchedItemBuilder(presentationMailbox: teamMailboxRoot),
      );

      expect(find.byType(DragTarget<List<PresentationEmail>>), findsNothing);
    });

    testWidgets('offers a top-level folder shared through ACL as drop target',
        (tester) async {
      await _pump(
        tester,
        MailboxSearchedItemBuilder(presentationMailbox: sharedTopLevelFolder),
      );

      expect(find.byType(DragTarget<List<PresentationEmail>>), findsOneWidget);
    });
  });
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(GetMaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Scaffold(body: child),
  ));
  await tester.pump();
}
