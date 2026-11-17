import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the `lib/main.dart` FocusScope placement from flutter/flutter#194056.
///
/// `FlutterSmartDialog` builds its own [Overlay] whose toast/dialog entries are
/// siblings of the navigator [FocusScope], so they sit in the View focus sort
/// unless an outer [FocusScope] wraps that whole overlay.
// TODO: delete with the lib/main.dart FocusScope once flutter/flutter#194056 is in our Flutter version.
void main() {
  testWidgets(
    'outer FocusScope keeps SmartDialog-style overlay focus out of the View sort',
    _outerFocusScopeKeepsOverlayOutOfViewSort,
  );

  testWidgets(
    'without an outer FocusScope, SmartDialog-style overlay focus attaches to the View',
    _withoutOuterFocusScopeOverlayAttachesToView,
  );

  testWidgets(
    'without an outer FocusScope, sorting the View during overlay deactivate throws',
    _withoutOuterFocusScopeSortDuringDeactivateThrows,
  );

  testWidgets(
    'outer FocusScope keeps View sort safe during overlay deactivate',
    _outerFocusScopeKeepsSortSafeDuringDeactivate,
  );
}

Future<void> _outerFocusScopeKeepsOverlayOutOfViewSort(WidgetTester tester) async {
  final overlayFocus = FocusNode(debugLabel: 'smart-dialog-overlay');
  addTearDown(overlayFocus.dispose);

  late OverlayEntry navigatorEntry;
  late OverlayEntry toastEntry;
  navigatorEntry = OverlayEntry(
    builder: (_) => const FocusScope(
      debugLabel: 'Navigator Scope',
      child: SizedBox(width: 40, height: 40),
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
              builder: (_) => const FocusScope(
                debugLabel: 'Navigator Scope',
                child: SizedBox(width: 40, height: 40),
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

Future<void> _withoutOuterFocusScopeSortDuringDeactivateThrows(WidgetTester tester) async {
  final thrown = await _sortViewDuringOverlayDeactivate(tester, outerScope: false);
  expect(
    thrown?.toString(),
    contains('Cannot get renderObject of inactive element'),
    reason: 'View sort must hit the inactive overlay focus without an outer FocusScope',
  );
}

Future<void> _outerFocusScopeKeepsSortSafeDuringDeactivate(WidgetTester tester) async {
  final thrown = await _sortViewDuringOverlayDeactivate(tester, outerScope: true);
  expect(
    thrown,
    isNull,
    reason: 'outer FocusScope must keep inactive overlay focus out of the View sort',
  );
}

Future<Object?> _sortViewDuringOverlayDeactivate(
  WidgetTester tester, {
  required bool outerScope,
}) async {
  final overlayFocus = FocusNode(debugLabel: 'smart-dialog-overlay');
  addTearDown(overlayFocus.dispose);

  late OverlayEntry toastEntry;
  toastEntry = OverlayEntry(
    builder: (_) => Column(
      children: [
        Focus(focusNode: overlayFocus, child: const SizedBox(width: 20, height: 20)),
        _SortDuringDeactivateProbe(),
      ],
    ),
  );
  final navigatorEntry = OverlayEntry(
    builder: (_) => const FocusScope(
      debugLabel: 'Navigator Scope',
      child: SizedBox(width: 40, height: 40),
    ),
  );

  final overlay = Overlay(initialEntries: [navigatorEntry, toastEntry]);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: FocusScope(
        debugLabel: 'View Scope',
        child: outerScope
            ? FocusScope(debugLabel: 'App Scope', child: overlay)
            : overlay,
      ),
    ),
  );
  overlayFocus.requestFocus();
  await tester.pump();

  _SortDuringDeactivateProbe.reset();
  toastEntry.remove();
  await tester.pump();
  expect(
    _SortDuringDeactivateProbe.sawDeactivate,
    isTrue,
    reason: 'overlay remove must run deactivate before the sort assertion',
  );
  return _SortDuringDeactivateProbe.thrown;
}

/// Runs [ReadingOrderTraversalPolicy.findFirstFocus] while this element is
/// inactive, matching the mid-frame View focus sort from flutter/flutter#194056.
class _SortDuringDeactivateProbe extends StatefulWidget {
  @override
  State<_SortDuringDeactivateProbe> createState() => _SortDuringDeactivateProbeState();

  static Object? thrown;
  static bool sawDeactivate = false;

  static void reset() {
    thrown = null;
    sawDeactivate = false;
  }
}

class _SortDuringDeactivateProbeState extends State<_SortDuringDeactivateProbe> {
  @override
  void deactivate() {
    _SortDuringDeactivateProbe.sawDeactivate = true;
    final viewScope = FocusManager.instance.rootScope.descendants
        .whereType<FocusScopeNode>()
        .firstWhere((node) => node.debugLabel == 'View Scope');
    try {
      ReadingOrderTraversalPolicy().findFirstFocus(viewScope, ignoreCurrentFocus: true);
    } catch (e) {
      _SortDuringDeactivateProbe.thrown = e;
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
