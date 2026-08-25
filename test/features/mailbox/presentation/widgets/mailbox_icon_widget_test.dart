import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';

void main() {
  group('MailboxIconWidget', () {
    testWidgets('renders every mailbox icon at 20px', (tester) async {
      await _pumpIcon(tester, brightness: Brightness.light);

      final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(icon.width, MailboxIconWidgetStyles.iconSize);
      expect(icon.height, MailboxIconWidgetStyles.iconSize);
      expect(MailboxIconWidgetStyles.iconSize, 20);
    });

    testWidgets('uses the legacy blue color and fit by default', (tester) async {
      await _pumpIcon(tester, brightness: Brightness.light);

      final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        icon.colorFilter,
        const ColorFilter.mode(AppColor.primaryLinShare, BlendMode.srcIn),
      );
      expect(icon.fit, BoxFit.fill);
    });

    testWidgets('keeps an explicit semantic color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MailboxIconWidget(
            icon: ImagePaths().icFolderMailbox,
            color: AppColor.primaryLinShare,
          ),
        ),
      ));

      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        const ColorFilter.mode(AppColor.primaryLinShare, BlendMode.srcIn),
      );
    });
  });
}

Future<void> _pumpIcon(
  WidgetTester tester, {
  required Brightness brightness,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(
      body: MailboxIconWidget(icon: ImagePaths().icMailboxInbox),
    ),
  ));
}
