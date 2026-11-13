import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/utils/primary_focus_logger.dart';

void main() {
  tearDown(PrimaryFocusLogger.instance.stop);

  testWidgets('start then stop leaves dump safe to call', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FocusScope(
          child: Focus(child: const SizedBox(width: 1, height: 1)),
        ),
      ),
    );

    final logger = PrimaryFocusLogger.instance;
    logger.start();
    logger.stop();
    expect(() => logger.dump(), returnsNormally);
  });

  testWidgets('dump does not throw when primary focus is null', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    final logger = PrimaryFocusLogger.instance;
    logger.start();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(() => logger.dump(), returnsNormally);
    logger.stop();
  });

  testWidgets('dump after many primary focus changes does not throw', (tester) async {
    final nodes = List.generate(25, (i) => FocusNode(debugLabel: 'n$i'));
    addTearDown(() {
      for (final node in nodes) {
        node.dispose();
      }
    });

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FocusScope(
          child: Column(
            children: [
              for (final node in nodes)
                Focus(focusNode: node, child: const SizedBox(width: 1, height: 1)),
            ],
          ),
        ),
      ),
    );

    final logger = PrimaryFocusLogger.instance;
    logger.start();
    for (final node in nodes) {
      node.requestFocus();
      await tester.pump();
    }
    expect(() => logger.dump(), returnsNormally);
  });
}
