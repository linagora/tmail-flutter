import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const fileName = 'qa23-301pages.pdf';
const textStyle = TextStyle(fontSize: 10);

void main() {
  group('MiddleEllipsisText', () {
    group('truncation', registerTruncationTests);
    group('file extension reservation', registerFileExtensionReservationTests);
    group('file extension detection', registerFileExtensionDetectionTests);
    group('measurement', registerMeasurementTests);
    group('cache', registerCacheTests);
  });
}

void registerTruncationTests() {
  testWidgets(
    'should display full text when it fits',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(fileLabel(), width: 500),
      'qa23-301pages.pdf',
    ),
  );
  testWidgets(
    'should display full text when it fits and preserveFileExtension is true',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(fileLabel(preserveFileExtension: true), width: 500),
      'qa23-301pages.pdf',
    ),
  );
  // 11 chars kept: 6 at start (rounded up), 5 at the end
  testWidgets(
    'should split kept characters by keepStartFraction when preserveFileExtension is false',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(fileLabel(), width: 150),
      'qa23-3...s.pdf',
    ),
  );
  testWidgets(
    'should not keep the extension when keepStartFraction keeps everything at the start and preserveFileExtension is false',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(fileLabel(keepStartFraction: 1), width: 110),
      'qa23-30...',
    ),
  );
}

void registerFileExtensionReservationTests() {
  testWidgets(
    'should keep the full file extension when preserveFileExtension is true',
    (tester) => verifyExtensionFitsAcrossWidths(tester, from: 80, to: 170),
  );
  // Room for 3 kept characters, the extension needs 4
  testWidgets(
    'should not keep the extension when there is no room for it',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(fileLabel(preserveFileExtension: true), width: 70),
      'qa...f',
    ),
  );
  testWidgets(
    'should keep the extension when it is narrower than a shorter candidate without it',
    verifyNarrowExtensionIsNotSkipped,
  );
  testWidgets(
    'should keep the extension when keepStartFraction keeps everything at the start',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(
        fileLabel(keepStartFraction: 1, preserveFileExtension: true),
        width: 110,
      ),
      'qa2....pdf',
    ),
  );
}

void registerFileExtensionDetectionTests() {
  testWidgets(
    'should not reserve end characters when the name has no extension',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(
        fileLabel(text: 'qa23-301pages', preserveFileExtension: true),
        width: 110,
      ),
      'qa23...ges',
    ),
  );
  testWidgets(
    'should not treat a leading dot as a file extension',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(
        fileLabel(text: '.qa23-301pages', preserveFileExtension: true),
        width: 110,
      ),
      '.qa2...ges',
    ),
  );
  // Room for 1 kept character: it goes to the start, not to the dot
  testWidgets(
    'should not treat a trailing dot as a file extension',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(
        fileLabel(text: 'qa23-301pages.', preserveFileExtension: true),
        width: 45,
      ),
      'q...',
    ),
  );
  // 9 kept characters: the default split already keeps `.gz` at the end
  testWidgets(
    'should only reserve the last extension when the name has several dots',
    (tester) => verifyDisplayedText(
      tester,
      buildApp(
        fileLabel(text: 'qa23-301pages.tar.gz', preserveFileExtension: true),
        width: 130,
      ),
      'qa23-...r.gz',
    ),
  );
}

void registerMeasurementTests() {
  testWidgets(
    'should fit on one line when the style inherits letter spacing from DefaultTextStyle',
    (tester) => verifyExtensionFitsAcrossWidths(
      tester,
      from: 90,
      to: 200,
      wrap: (child) => DefaultTextStyle.merge(
        style: const TextStyle(letterSpacing: 2),
        child: child,
      ),
    ),
  );
  testWidgets(
    'should fit on one line when the system text scale is applied',
    (tester) => verifyExtensionFitsAcrossWidths(
      tester,
      from: 110,
      to: 260,
      wrap: (child) => MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: child,
      ),
    ),
  );
  testWidgets(
    'should measure with the ambient style when no style is given',
    (tester) => verifyFitsInAmbientStyle(
      tester,
      const MiddleEllipsisText(fileName, preserveFileExtension: true),
      'qa23-....pdf',
    ),
  );
  testWidgets(
    'should not inherit the ambient letter spacing when the style does not inherit',
    (tester) => verifyFitsInAmbientStyle(
      tester,
      const MiddleEllipsisText(
        fileName,
        style: TextStyle(inherit: false, fontSize: 10),
      ),
      'qa23-3...es.pdf',
    ),
  );
}

void registerCacheTests() {
  testWidgets(
    'should truncate again when only the system text scale changes',
    verifyTruncatesAgainOnTextScaleChange,
  );
  testWidgets(
    'should truncate again when only preserveFileExtension changes',
    verifyTruncatesAgainOnPreserveFileExtensionChange,
  );
}

typedef WrapWidget = Widget Function(Widget child);

MiddleEllipsisText fileLabel({
  String text = fileName,
  double keepStartFraction = 0.5,
  bool preserveFileExtension = false,
}) => MiddleEllipsisText(
  text,
  style: textStyle,
  keepStartFraction: keepStartFraction,
  preserveFileExtension: preserveFileExtension,
);

/// [wrap] sits inside the [Scaffold], so it is not overridden by the ambient
/// style that [Scaffold] sets.
Widget buildApp(Widget label, {required double width, WrapWidget? wrap}) {
  final box = SizedBox(width: width, child: label);
  return MaterialApp(
    home: Scaffold(body: Center(child: wrap?.call(box) ?? box)),
  );
}

String displayedText(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text)).data!;

bool didExceedMaxLines(WidgetTester tester) => tester
    .renderObject<RenderParagraph>(find.byType(RichText))
    .didExceedMaxLines;

Future<void> verifyDisplayedText(
  WidgetTester tester,
  Widget app,
  String expected,
) async {
  await tester.pumpWidget(app);

  expect(displayedText(tester), expected);
  expect(didExceedMaxLines(tester), isFalse);
}

Future<void> verifyExtensionFitsAcrossWidths(
  WidgetTester tester, {
  required double from,
  required double to,
  WrapWidget? wrap,
}) async {
  final label = fileLabel(preserveFileExtension: true);
  for (double width = from; width < to; width += 10) {
    await tester.pumpWidget(buildApp(label, width: width, wrap: wrap));

    final text = displayedText(tester);
    expect(text, contains('...'), reason: 'width $width');
    expect(text, endsWith('.pdf'), reason: 'width $width: $text');
    expect(didExceedMaxLines(tester), isFalse, reason: 'width $width: $text');
  }
}

Future<void> verifyFitsInAmbientStyle(
  WidgetTester tester,
  MiddleEllipsisText label,
  String expected,
) => verifyDisplayedText(
  tester,
  buildApp(
    label,
    width: 150,
    wrap: (child) => DefaultTextStyle(
      style: const TextStyle(fontSize: 10, letterSpacing: 2),
      child: child,
    ),
  ),
  expected,
);

Future<void> verifyTruncatesAgainOnTextScaleChange(WidgetTester tester) async {
  final label = fileLabel(preserveFileExtension: true);
  Widget scaled(double scale) => buildApp(
    label,
    width: 150,
    wrap: (child) => MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: child,
    ),
  );

  await tester.pumpWidget(scaled(1));
  await tester.pumpWidget(scaled(1.5));

  expect(didExceedMaxLines(tester), isFalse, reason: displayedText(tester));
}

Future<void> verifyTruncatesAgainOnPreserveFileExtensionChange(
  WidgetTester tester,
) async {
  await verifyDisplayedText(
    tester,
    buildApp(fileLabel(), width: 110),
    'qa23...pdf',
  );
  await verifyDisplayedText(
    tester,
    buildApp(fileLabel(preserveFileExtension: true), width: 110),
    'qa2....pdf',
  );
}

/// With a proportional font, `....ii` (extension kept) is narrower than
/// `W...i` (a shorter candidate), so the extension must still be found.
Future<void> verifyNarrowExtensionIsNotSkipped(WidgetTester tester) async {
  await (FontLoader('Proportional')..addFont(rootBundle.load(
    'packages/linagora_design_flutter/assets/fonts/TwakeInter-Regular.ttf',
  ))).load();
  const style = TextStyle(fontFamily: 'Proportional', fontSize: 20, letterSpacing: 0);
  final painter = TextPainter(
    text: const TextSpan(text: '....ii', style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width + 1;
  painter.dispose();

  await verifyDisplayedText(
    tester,
    buildApp(
      const MiddleEllipsisText(
        'WWWWWW.ii',
        style: style,
        preserveFileExtension: true,
      ),
      width: width,
    ),
    '....ii',
  );
}
