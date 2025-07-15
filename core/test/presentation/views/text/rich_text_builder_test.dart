import 'package:core/presentation/extensions/list_extensions.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final normalTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.black,
    fontSize: 16,
  );
  final highlightTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.red,
    fontSize: 16,
  );
  Widget buildRichText({
    required String textOrigin,
    required String wordToStyle,
    String? preMarkedText,
    bool ensureHighlightVisible = false,
  }) => MaterialApp(home: Scaffold(
    body: RichTextBuilder(
      textOrigin: textOrigin,
      wordToStyle: wordToStyle,
      styleOrigin: normalTextStyle,
      styleWord: highlightTextStyle,
      preMarkedText: preMarkedText,
      ensureHighlightVisible: ensureHighlightVisible,
    ),
  ));

  Finder findNormalStyledText(String text, {int occurrence = 1}) {
    final normalSpan = TextSpan(text: text, style: normalTextStyle);
    return find.byWidgetPredicate((widget) {
      return widget is RichText
        && (widget.text as TextSpan).text == null
        && ((widget.text as TextSpan).children!.first as TextSpan).children!.contains(normalSpan)
        && ((widget.text as TextSpan).children!.first as TextSpan).children!.countOccurrences(normalSpan) == occurrence;
    });
  }

  Finder findUnfocusedHighlightStyledText(String text, {int occurrence = 1}) {
    final highlightSpan = TextSpan(text: text, style: highlightTextStyle);
    return find.byWidgetPredicate((widget) {
      return widget is RichText
        && (widget.text as TextSpan).children != null
        && ((widget.text as TextSpan).children!.first as TextSpan).children!.contains(highlightSpan)
        && ((widget.text as TextSpan).children!.first as TextSpan).children!.countOccurrences(highlightSpan) == occurrence;
    });
  }

  Finder findFocusedHighlightStyledText(String text) {
    return find.byWidgetPredicate((widget) {
      return widget is RichText
        && (widget.text as TextSpan).text == null
        && ((widget.text as TextSpan).children!.first as TextSpan)
          .children
          !.where((span) => span is WidgetSpan
            && span.child is Text
            && (span.child as Text).data == text
            && (span.child as Text).style == highlightTextStyle
            && span.child.key is GlobalKey)
          .isNotEmpty;
    });
  }

  group('rich text builder test:', () {
    testWidgets(
      'should not highlight any text '
      'when wordToStyle is empty '
      'and preMarkedText is null',
    (tester) async {
      // arrange
      const textOrigin = 'This is a test';
      final richText = buildRichText(
        textOrigin: textOrigin,
        wordToStyle: '',
      );
      
      // act
      await tester.pumpWidget(richText);
      
      // assert
      expect(
        findNormalStyledText(textOrigin),
        findsOneWidget,
      );
      expect(findFocusedHighlightStyledText(''), findsNothing);
      expect(findUnfocusedHighlightStyledText(''), findsNothing);
    });

    testWidgets(
      'should not highlight any text '
      'when textOrigin is empty '
      'and preMarkedText is null',
    (tester) async {
      // arrange
      const wordToStyle = 'This is a test';
      final richText = buildRichText(
        textOrigin: '',
        wordToStyle: wordToStyle,
      );
      
      // act
      await tester.pumpWidget(richText);
      
      // assert
      expect(
        findNormalStyledText(''),
        findsOneWidget,
      );
      expect(findFocusedHighlightStyledText(wordToStyle), findsNothing);
      expect(findUnfocusedHighlightStyledText(wordToStyle), findsNothing);
    });

    testWidgets(
      'should highlight text with wordToStyle '
      'when wordToStyle is not empty '
      'and preMarkedText is null',
    (tester) async {
      // arrange
      const textOrigin = 'This is a test of test';
      const wordToStyle = 'test';
      final richText = buildRichText(
        textOrigin: textOrigin,
        wordToStyle: wordToStyle,
      );
      final highlightStyledTexts = wordToStyle
        .allMatches(textOrigin)
        .map((match) => match.group(0)!)
        .toList();
      final focusedHighlightStyledText = highlightStyledTexts.first;
      final unfocusedHighlightStyledTexts = List.from(
        highlightStyledTexts.getRange(1, highlightStyledTexts.length));
      final normalStyledTexts = textOrigin
        .split(wordToStyle)
        ..removeWhere((text) => text.isEmpty);
      
      // act
      await tester.pumpWidget(richText);
      
      // assert
      for (final text in normalStyledTexts) {
        expect(
          findNormalStyledText(
            text,
            occurrence: normalStyledTexts.countOccurrences(text),
          ),
          findsOneWidget,
        );
      }
      for (final unfocusedHighlightStyledText in unfocusedHighlightStyledTexts) {
        expect(
          findUnfocusedHighlightStyledText(
            unfocusedHighlightStyledText,
            occurrence: unfocusedHighlightStyledTexts.countOccurrences(unfocusedHighlightStyledText),
          ),
          findsOneWidget,
        );
      }
      expect(
        findFocusedHighlightStyledText(focusedHighlightStyledText),
        findsOneWidget,
      );
    });

    testWidgets(
      'should highlight text with <mark> '
      'when preMarkedText is not null ',
    (tester) async {
      // arrange
      const preMarkedText = 'This is <mark>test</mark> '
        'of <mark>test text</mark> with duplicate <mark>test</mark>This is ';
      final richText = buildRichText(
        textOrigin: '',
        wordToStyle: '',
        preMarkedText: preMarkedText,
      );
      
      final highlightMatches = RegExp('<mark>(.*?)</mark>').allMatches(preMarkedText);
      final highlightStyledTexts = highlightMatches
        .map((match) => match.group(1)!)
        .toList();
      final focusedHighlightStyledText = highlightStyledTexts.first;
      final unfocusedHighlightStyledTexts = List.from(
        highlightStyledTexts.getRange(1, highlightStyledTexts.length));
      final normalStyledTexts = <String>[];
      int lastIndex = 0;
      for (final match in highlightMatches) {
        normalStyledTexts.add(preMarkedText.substring(lastIndex, match.start));
        lastIndex = match.end;
      }
      normalStyledTexts
        ..add(preMarkedText.substring(lastIndex))
        ..removeWhere((text) => text.isEmpty);
      
      // act
      await tester.pumpWidget(richText);
      
      // assert
      for (final text in normalStyledTexts) {
        expect(
          findNormalStyledText(
            text,
            occurrence: normalStyledTexts.countOccurrences(text),  
          ),
          findsOneWidget,
        );
      }
      for (final unfocusedHighlightStyledText in unfocusedHighlightStyledTexts) {
        expect(
          findUnfocusedHighlightStyledText(
            unfocusedHighlightStyledText,
            occurrence: unfocusedHighlightStyledTexts.countOccurrences(unfocusedHighlightStyledText),
          ),
          findsOneWidget,
        );
      }
      expect(
        findFocusedHighlightStyledText(focusedHighlightStyledText),
        findsOneWidget,
      );
    });

    testWidgets(
      'should highlight text with <mark> '
      'when preMarkedText is not null '
      'and both textOrigin and wordToStyle are not empty',
    (tester) async {
      // arrange
      const preMarkedText = 'This is <mark>test</mark> '
        'of <mark>test text</mark> with duplicate <mark>test</mark>';
      final richText = buildRichText(
        textOrigin: 'something something',
        wordToStyle: 'some',
        preMarkedText: preMarkedText,
      );
      
      final highlightMatches = RegExp('<mark>(.*?)</mark>').allMatches(preMarkedText);
      final highlightStyledTexts = highlightMatches
        .map((match) => match.group(1)!)
        .toList();
      final focusedHighlightStyledText = highlightStyledTexts.first;
      final unfocusedHighlightStyledTexts = List.from(
        highlightStyledTexts.getRange(1, highlightStyledTexts.length));
      final normalStyledTexts = <String>[];
      int lastIndex = 0;
      for (final match in highlightMatches) {
        normalStyledTexts.add(preMarkedText.substring(lastIndex, match.start));
        lastIndex = match.end;
      }
      normalStyledTexts
        ..add(preMarkedText.substring(lastIndex))
        ..removeWhere((text) => text.isEmpty);
      
      // act
      await tester.pumpWidget(richText);
      
      // assert
      for (final text in normalStyledTexts) {
        expect(
          findNormalStyledText(text),
          findsOneWidget,
        );
      }
      for (final unfocusedHighlightStyledText in unfocusedHighlightStyledTexts) {
        expect(
          findUnfocusedHighlightStyledText(
            unfocusedHighlightStyledText,
            occurrence: unfocusedHighlightStyledTexts.countOccurrences(unfocusedHighlightStyledText),
          ),
          findsOneWidget,
        );
      }
      expect(
        findFocusedHighlightStyledText(focusedHighlightStyledText),
        findsOneWidget,
      );
    });
  });
}