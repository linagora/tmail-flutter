import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal_shell.dart';

const _closeIcon = 'assets/close.svg';

Widget _shell({
  required bool haveCloseButton,
  required BoxConstraints constraints,
  required EdgeInsets insetPadding,
  Widget Function(TMailButtonWidget closeButton)? loadingWidget,
  VoidCallback? onClose,
}) {
  return MaterialApp(
    home: _modalShell(
      haveCloseButton: haveCloseButton,
      constraints: constraints,
      insetPadding: insetPadding,
      loadingWidget: loadingWidget,
      onClose: onClose,
    ),
  );
}

Widget _modalShell({
  required bool haveCloseButton,
  required BoxConstraints constraints,
  required EdgeInsets insetPadding,
  Widget Function(TMailButtonWidget closeButton)? loadingWidget,
  VoidCallback? onClose,
}) {
  return DriveIntentWebViewModalShell(
    closeIconPath: _closeIcon,
    onClose: onClose ?? () {},
    constraints: constraints,
    insetPadding: insetPadding,
    loadingWidget: loadingWidget,
    child: const SizedBox.shrink(),
  );
}

void main() {
  group('DriveIntentWebViewModalShell', () {
    _testLoadingOverlayIsClosable();
    _testLoadingOverlayCloseButtonCallback();
    _testCloseButtonHoverFeedback();
    _testNoPointerInterceptorWithoutLoadingOverlay();
  });
}

void _testLoadingOverlayIsClosable() {
  testWidgets(
    'loading overlay is always closable — receives a close button',
    (tester) async {
      TMailButtonWidget? received;
      await tester.pumpWidget(
        _shell(
          haveCloseButton: false,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
          insetPadding: const EdgeInsets.all(24),
          loadingWidget: (closeButton) {
            received = closeButton;
            return closeButton;
          },
        ),
      );

      expect(received, isNotNull);
      expect(find.byWidget(received!), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(PointerInterceptor),
          matching: find.byType(Positioned),
        ),
        findsOneWidget,
      );
    },
  );
}

void _testLoadingOverlayCloseButtonCallback() {
  testWidgets('loading overlay close button is wired to onClose', (
    tester,
  ) async {
    var closed = 0;
    TMailButtonWidget? received;
    await tester.pumpWidget(
      _shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
        onClose: () => closed++,
        loadingWidget: (closeButton) {
          received = closeButton;
          return closeButton;
        },
      ),
    );

    // Assert callback wiring without SVG hit-testing.
    received!.onTapActionCallback!();
    expect(closed, 1);
  });
}

void _testCloseButtonHoverFeedback() {
  testWidgets('close button keeps Material hover feedback', (tester) async {
    await tester.pumpWidget(
      _shell(
        haveCloseButton: true,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
      ),
    );

    final button = tester.widget<TMailButtonWidget>(
      find.byType(TMailButtonWidget),
    );

    expect(button.hoverColor, const Color(0x14424244));
  });
}

void _testNoPointerInterceptorWithoutLoadingOverlay() {
  testWidgets('does not intercept pointers without a loading overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      _shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
      ),
    );

    expect(find.byType(PointerInterceptor), findsNothing);
  });
}
