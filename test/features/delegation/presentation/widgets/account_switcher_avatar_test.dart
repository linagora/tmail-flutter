import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/account_switcher_avatar.dart';

void main() {
  testWidgets('sizes the avatar and initials to the given diameter',
      (tester) async {
    const size = 40.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: accountSwitcherAvatar('bob@example.com', size),
        ),
      ),
    );

    expect(find.text('B'), findsOneWidget);

    final avatarFinder =
        find.ancestor(of: find.text('B'), matching: find.byType(Container)).first;
    expect(tester.getSize(avatarFinder), const Size(size, size));

    final initials = tester.widget<Text>(find.text('B'));
    expect(initials.style?.fontSize, size * 0.44);
  });
}
