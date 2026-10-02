import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fileName = 'qa23-301pages.pdf';
  const textStyle = TextStyle(fontSize: 10);

  Widget buildWidget({
    required double width,
    String text = fileName,
    bool preserveFileExtension = false,
  }) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: MiddleEllipsisText(
            text,
            style: textStyle,
            preserveFileExtension: preserveFileExtension,
          ),
        ),
      ),
    ),
  );

  String displayedText(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text)).data!;

  bool didExceedMaxLines(WidgetTester tester) => tester
      .renderObject<RenderParagraph>(find.byType(RichText))
      .didExceedMaxLines;

  group('MiddleEllipsisText', () {
    testWidgets('should display full text when it fits', (tester) async {
      await tester.pumpWidget(buildWidget(width: 500));

      expect(displayedText(tester), fileName);
    });

    testWidgets(
      'should keep the full file extension when preserveFileExtension is true',
      (tester) async {
        for (double width = 80; width < 170; width += 10) {
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
        await tester.pumpWidget(buildWidget(width: 150));

        expect(displayedText(tester), 'qa23-3...s.pdf');
      },
    );

    testWidgets(
      'should fit on one line when the style inherits letter spacing from DefaultTextStyle',
      (tester) async {
        for (double width = 90; width < 200; width += 10) {
          await tester.pumpWidget(
            DefaultTextStyle.merge(
              style: const TextStyle(letterSpacing: 2),
              child: buildWidget(width: width, preserveFileExtension: true),
            ),
          );

          final text = displayedText(tester);
          expect(text, endsWith('.pdf'), reason: 'width $width: $text');
          expect(didExceedMaxLines(tester), isFalse, reason: 'width $width: $text');
        }
      },
    );

    testWidgets(
      'should fit on one line when the system text scale is applied',
      (tester) async {
        for (double width = 110; width < 260; width += 10) {
          await tester.pumpWidget(
            MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: buildWidget(width: width, preserveFileExtension: true),
            ),
          );

          final text = displayedText(tester);
          expect(text, endsWith('.pdf'), reason: 'width $width: $text');
          expect(didExceedMaxLines(tester), isFalse, reason: 'width $width: $text');
        }
      },
    );

    testWidgets(
      'should truncate again when only the system text scale changes',
      (tester) async {
        Widget scaled(double scale) => MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: buildWidget(width: 150, preserveFileExtension: true),
        );

        await tester.pumpWidget(scaled(1));
        await tester.pumpWidget(scaled(1.5));

        expect(didExceedMaxLines(tester), isFalse, reason: displayedText(tester));
      },
    );

    testWidgets(
      'should not treat a trailing dot as a file extension',
      (tester) async {
        // Room for 1 kept character: it goes to the start, not to the dot
        await tester.pumpWidget(buildWidget(
          width: 45,
          text: 'qa23-301pages.',
          preserveFileExtension: true,
        ));

        expect(displayedText(tester), 'q...');
      },
    );
  });
}
