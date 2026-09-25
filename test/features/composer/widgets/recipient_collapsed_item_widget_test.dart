import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_collapsed_item_widget.dart';

void main() {
  group('RecipientCollapsedItemWidget test', () {
    Widget makeTestableWidget({required Widget child}) {
      return MaterialApp(home: Scaffold(body: child));
    }

    Border tagBorder(WidgetTester tester) {
      final Container tagContainer = tester.widget(find.byType(Container).first);
      return (tagContainer.decoration as BoxDecoration).border as Border;
    }

    testWidgets('WHEN isRejectedByServer is true\n'
        'RecipientCollapsedItemWidget should show the invalid-address border', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        child: RecipientCollapsedItemWidget(
          emailAddress: EmailAddress(null, 'rejected@dev.com'),
          isRejectedByServer: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(tagBorder(tester).top.color, AppColor.colorBorderEmailAddressInvalid);
    });

    testWidgets('WHEN isRejectedByServer is false\n'
        'RecipientCollapsedItemWidget should show the default border', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        child: RecipientCollapsedItemWidget(
          emailAddress: EmailAddress(null, 'accepted@dev.com'),
          isRejectedByServer: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(tagBorder(tester).top.color, AppColor.grayBackgroundColor);
    });
  });
}
