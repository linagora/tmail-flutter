import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/expand_folder_trigger_scrollable_mixin.dart';

void main() {
  testWidgets(
    'triggerScrollWhenExpandFolder scrolls the expanded item into view',
    _scrollsWhenItemKeyAndScrollControllerGiven,
  );

  testWidgets(
    'triggerScrollWhenExpandFolder does nothing when the folder is collapsed',
    _doesNotScrollWhenFolderCollapsed,
  );
}

Future<void> _scrollsWhenItemKeyAndScrollControllerGiven(
  WidgetTester tester,
) async {
  final itemKey = GlobalKey();
  final scrollController = await _pumpFolderList(tester, itemKey);

  _ExpandFolderHost().triggerScrollWhenExpandFolder(
    ExpandMode.EXPAND,
    itemKey,
    scrollController,
  );
  await tester.pumpAndSettle();

  expect(scrollController.offset, greaterThan(0));
}

Future<void> _doesNotScrollWhenFolderCollapsed(WidgetTester tester) async {
  final itemKey = GlobalKey();
  final scrollController = await _pumpFolderList(tester, itemKey);

  _ExpandFolderHost().triggerScrollWhenExpandFolder(
    ExpandMode.COLLAPSE,
    itemKey,
    scrollController,
  );
  await tester.pumpAndSettle();

  expect(scrollController.offset, 0);
}

/// Pumps a folder list whose keyed item sits at the bottom edge of the
/// viewport, so expanding it requires scrolling.
Future<ScrollController> _pumpFolderList(
  WidgetTester tester,
  GlobalKey itemKey,
) async {
  const keyedItemIndex = 5;
  final scrollController = ScrollController();
  addTearDown(scrollController.dispose);
  tester.view.physicalSize =
      const Size(800, 600) * tester.view.devicePixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        controller: scrollController,
        itemCount: 20,
        itemBuilder: (_, index) => SizedBox(
          key: index == keyedItemIndex ? itemKey : null,
          height: 100,
          child: Text('folder $index'),
        ),
      ),
    ),
  ));

  return scrollController;
}

class _ExpandFolderHost with ExpandFolderTriggerScrollableMixin {}
