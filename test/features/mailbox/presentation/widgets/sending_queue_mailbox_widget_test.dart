import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sending_queue_mailbox_widget.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  testWidgets('uses the shared sidebar row style and opens the sending queue',
      (tester) async {
    var opened = false;
    final style = LinagoraSidebarStyle.light();

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.light(),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: Scaffold(
        body: SendingQueueMailboxWidget(
          imagePaths: ImagePaths(),
          listSendingEmails: List<SendingEmail>.filled(
            1000,
            _FakeSendingEmail(),
          ),
          isSelected: true,
          onOpenSendingQueueAction: () => opened = true,
        ),
      ),
    ));
    await tester.pump();

    final row = tester.widget<LinagoraSidebarItem>(
      find.byType(LinagoraSidebarItem),
    );
    final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));

    expect(row.active, isTrue);
    expect(row.badgeLabel, '999+');
    expect(icon.width, style.itemIconSize);
    expect(icon.height, style.itemIconSize);
    expect(
      icon.colorFilter,
      ColorFilter.mode(style.activeForeground, BlendMode.srcIn),
    );

    await tester.tap(find.byType(LinagoraSidebarItem));
    await tester.pump();

    expect(opened, isTrue);
  });
}

class _FakeSendingEmail extends Fake implements SendingEmail {}
