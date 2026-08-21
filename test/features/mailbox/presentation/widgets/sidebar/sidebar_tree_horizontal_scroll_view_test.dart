import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';

void main() {
  for (final scenario in [
    (
      description: 'keeps the mobile and tablet scrollbar visible',
      thumbVisibility: true,
      trackVisibility: true,
    ),
    (
      description: 'shows the desktop scrollbar only while scrolling',
      thumbVisibility: false,
      trackVisibility: false,
    ),
  ]) {
    testWidgets(
      scenario.description,
      (tester) => _verifyScrollbarVisibility(tester, scenario),
    );
  }
}

Future<void> _verifyScrollbarVisibility(
  WidgetTester tester,
  ({String description, bool thumbVisibility, bool trackVisibility}) scenario,
) async {
  final verticalController = ScrollController();
  addTearDown(verticalController.dispose);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: ResponsiveUtils.sidebarMenuWidth,
        height: 240,
        child: ScrollbarListView(
          scrollController: verticalController,
          notificationPredicate:
              ScrollbarListView.isVerticalScrollNotification,
          thumbVisibility: scenario.thumbVisibility,
          trackVisibility: scenario.trackVisibility,
          child: LinagoraSidebarMenu(
            controller: verticalController,
            treeHorizontalOverflow: 48,
            navigationItems: List.generate(
              40,
              (index) => SizedBox(
                height: 40,
                child: Text('Folder $index'),
              ),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();

  final scrollbar = tester.widget<RawScrollbar>(
    find.byWidgetPredicate(
      (widget) =>
          widget is RawScrollbar &&
          identical(widget.controller, verticalController),
    ),
  );
  final context = tester.element(find.byType(ScrollbarListView));

  expect(scrollbar.thumbVisibility, scenario.thumbVisibility);
  expect(scrollbar.trackVisibility, scenario.trackVisibility);
  expect(scrollbar.interactive, isTrue);
  expect(
    scrollbar.notificationPredicate(_scrollNotification(
      context,
      axisDirection: AxisDirection.down,
      depth: 1,
    )),
    isTrue,
  );
  expect(
    scrollbar.notificationPredicate(_scrollNotification(
      context,
      axisDirection: AxisDirection.right,
    )),
    isFalse,
  );
}

ScrollUpdateNotification _scrollNotification(
  BuildContext context, {
  required AxisDirection axisDirection,
  int? depth,
}) =>
    ScrollUpdateNotification(
      context: context,
      depth: depth,
      metrics: FixedScrollMetrics(
        axisDirection: axisDirection,
        devicePixelRatio: 1,
        maxScrollExtent: 48,
        minScrollExtent: 0,
        pixels: 0,
        viewportDimension: 240,
      ),
    );
