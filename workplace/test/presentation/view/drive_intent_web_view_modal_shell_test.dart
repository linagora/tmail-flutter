import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal_shell.dart';

// Represents the iframe/platform view across resize.
class _ProbeChild extends StatefulWidget {
  const _ProbeChild({super.key});

  @override
  State<_ProbeChild> createState() => _ProbeChildState();
}

class _ProbeChildState extends State<_ProbeChild> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

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

Widget _responsiveShell({required bool isWideScreen}) {
  return MaterialApp(
    home: Stack(
      children: [
        Positioned.fill(
          child: PointerInterceptor(child: const SizedBox.expand()),
        ),
        SafeArea(
          top: !isWideScreen,
          left: false,
          right: false,
          bottom: false,
          child: _modalShell(
            haveCloseButton: !isWideScreen,
            constraints: isWideScreen
                ? const BoxConstraints(maxWidth: 800, maxHeight: 677)
                : const BoxConstraints.expand(),
            insetPadding:
                isWideScreen ? const EdgeInsets.all(24) : EdgeInsets.zero,
          ),
        ),
      ],
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
    haveCloseButton: haveCloseButton,
    constraints: constraints,
    insetPadding: insetPadding,
    loadingWidget: loadingWidget,
    child: const _ProbeChild(key: ValueKey('probe')),
  );
}

void main() {
  group('DriveIntentWebViewModalShell', () {
    testWidgets(
      'preserves platform child in both resize directions (#4738)',
      (tester) async {
        await tester.pumpWidget(_responsiveShell(isWideScreen: true));
        final stateBefore =
            tester.state<_ProbeChildState>(find.byType(_ProbeChild));

        await tester.pumpWidget(_responsiveShell(isWideScreen: false));
        final mobileState =
            tester.state<_ProbeChildState>(find.byType(_ProbeChild));

        expect(identical(stateBefore, mobileState), isTrue);

        await tester.pumpWidget(_responsiveShell(isWideScreen: true));
        final wideState =
            tester.state<_ProbeChildState>(find.byType(_ProbeChild));

        expect(identical(stateBefore, wideState), isTrue);
      },
    );

    testWidgets('loading overlay is always closable — receives a close button',
        (tester) async {
      TMailButtonWidget? received;
      await tester.pumpWidget(_shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
        loadingWidget: (closeButton) {
          received = closeButton;
          return closeButton;
        },
      ));

      expect(received, isNotNull);
      expect(find.byWidget(received!), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(PointerInterceptor),
          matching: find.byType(Positioned),
        ),
        findsOneWidget,
      );
    });

    testWidgets('loading overlay close button is wired to onClose',
        (tester) async {
      var closed = 0;
      TMailButtonWidget? received;
      await tester.pumpWidget(_shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
        onClose: () => closed++,
        loadingWidget: (closeButton) {
          received = closeButton;
          return closeButton;
        },
      ));

      // Assert callback wiring without SVG hit-testing.
      received!.onTapActionCallback!();
      expect(closed, 1);
    });

    testWidgets('close button keeps Material hover feedback', (tester) async {
      await tester.pumpWidget(_shell(
        haveCloseButton: true,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
      ));

      final button = tester.widget<TMailButtonWidget>(
        find.byType(TMailButtonWidget),
      );

      expect(button.hoverColor, const Color(0x14424244));
    });

    testWidgets('does not intercept pointers without a loading overlay',
        (tester) async {
      await tester.pumpWidget(_shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
      ));

      expect(find.byType(PointerInterceptor), findsNothing);
    });
  });
}
