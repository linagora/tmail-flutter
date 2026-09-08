import 'package:core/presentation/utils/web_selection/web_selection_coordinator.dart';
import 'package:core/presentation/utils/web_selection/web_selection_dom_adapter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDomAdapter implements WebSelectionDomAdapter {
  int clearIframeSelectionsCalls = 0;
  bool iframeFocused = false;
  void Function()? blurHandler;

  @override
  void clearIframeSelections() => clearIframeSelectionsCalls++;

  @override
  bool get isIframeFocused => iframeFocused;

  @override
  void addTopWindowBlurListener(void Function() handler) =>
      blurHandler = handler;

  @override
  void removeTopWindowBlurListener() => blurHandler = null;
}

void main() {
  late _FakeDomAdapter dom;
  late WebSelectionCoordinator coordinator;
  late FocusNode regionFocusNode;
  late FocusNode textFieldFocusNode;
  SelectedContent? lastSelection;

  setUp(() {
    dom = _FakeDomAdapter();
    coordinator = WebSelectionCoordinator(dom: dom);
    regionFocusNode = FocusNode();
    textFieldFocusNode = FocusNode();
    lastSelection = null;
  });

  tearDown(() {
    coordinator.stop();
    regionFocusNode.dispose();
    textFieldFocusNode.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SelectionArea(
                focusNode: regionFocusNode,
                onSelectionChanged: (selection) => lastSelection = selection,
                child: const Text('Subject line to select'),
              ),
              TextField(focusNode: textFieldFocusNode),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectSubjectWithMouse(WidgetTester tester) async {
    final textRect = tester.getRect(find.text('Subject line to select'));
    final gesture = await tester.startGesture(
      textRect.centerLeft + const Offset(2, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(textRect.centerRight - const Offset(2, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  // Browser moved focus into an iframe and blurred the top window.
  Future<void> focusIframe(WidgetTester tester) async {
    dom.iframeFocused = true;
    dom.blurHandler!();
    await tester.pump(const Duration(milliseconds: 1));
  }

  group('WebSelectionCoordinator', () {
    testWidgets('start registers listeners once and stop removes them',
        (tester) async {
      await pumpApp(tester);

      coordinator.start();
      coordinator.start();
      expect(coordinator.isStarted, isTrue);
      expect(dom.blurHandler, isNotNull);

      coordinator.stop();
      expect(coordinator.isStarted, isFalse);
      expect(dom.blurHandler, isNull);
    });

    testWidgets('clears iframe selections when a SelectableRegion takes focus',
        (tester) async {
      await pumpApp(tester);
      coordinator.start();

      await selectSubjectWithMouse(tester);

      expect(lastSelection?.plainText, 'Subject line to select');
      expect(dom.clearIframeSelectionsCalls, 1);
    });

    testWidgets('ignores focus moving to a non-selection widget',
        (tester) async {
      await pumpApp(tester);
      coordinator.start();

      textFieldFocusNode.requestFocus();
      await tester.pump();

      expect(dom.clearIframeSelectionsCalls, 0);
    });

    testWidgets('clears the Flutter selection when focus lands in an iframe',
        (tester) async {
      await pumpApp(tester);
      coordinator.start();
      await selectSubjectWithMouse(tester);
      expect(lastSelection, isNotNull);

      await focusIframe(tester);

      expect(lastSelection, isNull);
      expect(regionFocusNode.hasFocus, isFalse);
      // Unfocusing the region must not trigger another iframe clear.
      expect(dom.clearIframeSelectionsCalls, 1);
    });

    testWidgets('a second blur while the iframe stays focused is harmless',
        (tester) async {
      await pumpApp(tester);
      coordinator.start();
      await selectSubjectWithMouse(tester);

      await focusIframe(tester);
      await focusIframe(tester);

      expect(lastSelection, isNull);
      expect(regionFocusNode.hasFocus, isFalse);
      expect(dom.clearIframeSelectionsCalls, 1);
    });

    testWidgets('keeps the Flutter selection when blur is not an iframe',
        (tester) async {
      await pumpApp(tester);
      coordinator.start();
      await selectSubjectWithMouse(tester);

      dom.iframeFocused = false;
      dom.blurHandler!();
      await tester.pump(const Duration(milliseconds: 1));

      expect(lastSelection, isNotNull);
      expect(regionFocusNode.hasFocus, isTrue);
    });

    testWidgets('does nothing after stop', (tester) async {
      await pumpApp(tester);
      coordinator.start();
      coordinator.stop();

      await selectSubjectWithMouse(tester);

      expect(dom.clearIframeSelectionsCalls, 0);
    });
  });
}
