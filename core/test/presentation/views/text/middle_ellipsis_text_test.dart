import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fileName = 'qa23-301pages.pdf';
  const textStyle = TextStyle(fontSize: 10);

  Widget buildWidget({
    required double width,
    bool preserveFileExtension = false,
  }) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: MiddleEllipsisText(
            fileName,
            style: textStyle,
            preserveFileExtension: preserveFileExtension,
          ),
        ),
      ),
    ),
  );

  String displayedText(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text)).data!;

  group('MiddleEllipsisText', () {
    testWidgets('should display full text when it fits', (tester) async {
      await tester.pumpWidget(buildWidget(width: 500));

      expect(displayedText(tester), fileName);
    });

    testWidgets(
      'should keep the full file extension when preserveFileExtension is true',
      (tester) async {
        for (double width = 70; width < 170; width += 10) {
          await tester.pumpWidget(buildWidget(
            width: width,
            preserveFileExtension: true,
          ));

          final text = displayedText(tester);
          expect(text, contains('...'), reason: 'width $width');
          expect(text, endsWith('.pdf'), reason: 'width $width: $text');
        }
      },
    );

    testWidgets(
      'should split kept characters by keepStartFraction when preserveFileExtension is false',
      (tester) async {
        // 11 chars kept: 6 at start (rounded up), 5 at the end
        await tester.pumpWidget(buildWidget(width: 140));

        expect(displayedText(tester), 'qa23-3...s.pdf');
      },
    );
  });
}
