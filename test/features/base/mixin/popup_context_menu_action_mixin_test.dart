import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';

void main() {
  testWidgets('opens a root popup menu from a nested navigator', (tester) async {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final nestedNavigatorKey = GlobalKey<NavigatorState>();
    late BuildContext nestedContext;
    final host = _PopupMenuHost();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: Navigator(
          key: nestedNavigatorKey,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) {
              nestedContext = context;
              return const Scaffold(body: SizedBox.expand());
            },
          ),
        ),
      ),
    );

    final openedMenu = host.openPopupMenuAction(
      nestedContext,
      const RelativeRect.fromLTRB(0, 0, 400, 800),
      const [PopupMenuItem<void>(child: Text('Root menu item'))],
      options: const PopupMenuActionOptions(useRootNavigator: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Root menu item'), findsOneWidget);
    expect(rootNavigatorKey.currentState!.canPop(), isTrue);
    expect(nestedNavigatorKey.currentState!.canPop(), isFalse);

    rootNavigatorKey.currentState!.pop();
    await openedMenu;
    await tester.pumpAndSettle();

    final nestedMenu = host.openPopupMenuAction(
      nestedContext,
      const RelativeRect.fromLTRB(0, 0, 400, 800),
      const [PopupMenuItem<void>(child: Text('Nested menu item'))],
    );
    await tester.pumpAndSettle();

    expect(find.text('Nested menu item'), findsOneWidget);
    expect(rootNavigatorKey.currentState!.canPop(), isFalse);
    expect(nestedNavigatorKey.currentState!.canPop(), isTrue);

    nestedNavigatorKey.currentState!.pop();
    await nestedMenu;
    await tester.pumpAndSettle();
  });
}

class _PopupMenuHost with PopupContextMenuActionMixin {}
