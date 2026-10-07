import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../marionette/marionette_mcp_binding.dart';

void main() {
  group('MarionetteMcpBinding.extractTMailText', () {
    Future<String?> extractFrom(WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      final element = tester.element(find.byWidget(widget));
      return MarionetteMcpBinding.extractTMailText(element);
    }

    testWidgets('returns the button text', (tester) async {
      expect(
        await extractFrom(tester, const TMailButtonWidget(text: 'Send')),
        'Send',
      );
    });

    testWidgets('falls back to the tooltip for an icon-only button', (
      tester,
    ) async {
      expect(
        await extractFrom(
          tester,
          TMailButtonWidget.fromIcon(
            icon: 'assets/images/ic_attach_file.svg',
            tooltipMessage: 'Attach',
          ),
        ),
        'Attach',
      );
    });

    testWidgets('returns the container tooltip', (tester) async {
      expect(
        await extractFrom(
          tester,
          const TMailContainerWidget(
            tooltipMessage: 'More',
            child: SizedBox.shrink(),
          ),
        ),
        'More',
      );
    });

    testWidgets('returns null for other widgets', (tester) async {
      expect(await extractFrom(tester, const Text('Plain')), isNull);
    });
  });
}
