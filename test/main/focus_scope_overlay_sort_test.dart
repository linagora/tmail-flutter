import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the `lib/main.dart` FocusScope placement from flutter/flutter#194056.
///
/// `FlutterSmartDialog` builds its own [Overlay] whose toast/dialog entries are
/// siblings of the navigator [FocusScope], so they sit in the View focus sort
/// unless an outer [FocusScope] wraps that whole overlay.
void main() {
  testWidgets(
    'outer FocusScope keeps SmartDialog-style overlay focus out of the View sort',
    _outerFocusScopeKeepsOverlayOutOfViewSort,
  );

  testWidgets(
    'without an outer FocusScope, SmartDialog-style overlay focus attaches to the View',
    _withoutOuterFocusScopeOverlayAttachesToView,
  );
}

Future<void> _outerFocusScopeKeepsOverlayOutOfViewSort(WidgetTester tester) async {
  final overlayFocus = FocusNode(debugLabel: 'smart-dialog-overlay');
  addTearDown(overlayFocus.dispose);

  late OverlayEntry navigatorEntry;
  late OverlayEntry toastEntry;
  navigatorEntry = OverlayEntry(
    builder: (_) => FocusScope(
      debugLabel: 'Navigator Scope',
      child: const SizedBox(width: 40, height: 40),
    ),
  );
  toastEntry = OverlayEntry(
    builder: (_) => Focus(
      focusNode: overlayFocus,
      child: const SizedBox(width: 20, height: 20),
    ),
  );

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: FocusScope(
        debugLabel: 'View Scope',
        child: FocusScope(
          debugLabel: 'App Scope',
          child: Overlay(initialEntries: [navigatorEntry, toastEntry]),
        ),
      ),
    ),
  );

  expect(
    overlayFocus.enclosingScope?.debugLabel,
    'App Scope',
    reason: 'overlay focus must attach under the outer App Scope, not the View',
  );

  final viewScope = FocusManager.instance.rootScope.descendants
      .whereType<FocusScopeNode>()
      .firstWhere((node) => node.debugLabel == 'View Scope');
  final policy = ReadingOrderTraversalPolicy();

  toastEntry.remove();
  // Sort while the focus node can still be in the tree with a detached element,
  // matching the View didChangeViewFocus timing from #194056.
  expect(
    () => policy.findFirstFocus(viewScope, ignoreCurrentFocus: true),
    returnsNormally,
  );
  await tester.pump();
}

Future<void> _withoutOuterFocusScopeOverlayAttachesToView(WidgetTester tester) async {
  final overlayFocus = FocusNode(debugLabel: 'smart-dialog-overlay');
  addTearDown(overlayFocus.dispose);

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: FocusScope(
        debugLabel: 'View Scope',
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (_) => FocusScope(
                debugLabel: 'Navigator Scope',
                child: const SizedBox(width: 40, height: 40),
              ),
            ),
            OverlayEntry(
              builder: (_) => Focus(
                focusNode: overlayFocus,
                child: const SizedBox(width: 20, height: 20),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  expect(
    overlayFocus.enclosingScope?.debugLabel,
    'View Scope',
    reason: 'regression pin. without the outer scope, overlay focus is sorted by the View',
  );
}
