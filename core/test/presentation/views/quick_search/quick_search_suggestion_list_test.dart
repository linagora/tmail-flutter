import 'dart:async';

import 'package:core/presentation/views/quick_search/quick_search_suggestion_box.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box_decoration.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuickSearchSuggestionList dispose lifecycle', () {
    // Regression tests for Sentry-373586:
    // AnimationController.stop crash when widget is disposed while an async
    // suggestion callback is still in flight.

    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Future<QuickSearchSuggestionsBox> buildSuggestionsBox(
      WidgetTester tester,
    ) async {
      late QuickSearchSuggestionsBox box;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            box = QuickSearchSuggestionsBox(
              context,
              AxisDirection.down,
              false,
              false,
            );
            return const SizedBox.shrink();
          }),
        ),
      ));
      return box;
    }

    testWidgets(
      'no crash when disposed while non-empty query Future.wait is pending',
      (tester) async {
        // Sentry-373586: _getSuggestions awaits Future.wait, widget is disposed,
        // then the future resolves — previously threw AnimationController.stop crash.
        final completer = Completer<List<String>>();
        controller.text = 'query';

        final suggestionsBox = await buildSuggestionsBox(tester);

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: QuickSearchSuggestionList<String, String, String>(
              suggestionsBox: suggestionsBox,
              controller: controller,
              suggestionsCallback: (_) => completer.future,
              animationDuration: const Duration(milliseconds: 300),
              animationStart: 0.0,
              decoration: const QuickSearchSuggestionsBoxDecoration(),
              getImmediateSuggestions: true,
              minCharsForSuggestions: 0,
            ),
          ),
        ));

        // Let initState fire _getSuggestions; suspends at Future.wait.
        await tester.pump();

        // Simulate navigating away — disposes the widget mid-flight.
        await tester.pumpWidget(const SizedBox());

        // Resolving future must not crash (mounted check guards the setState).
        completer.complete([]);
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'no crash when disposed while empty query _getListRecent is pending',
      (tester) async {
        // Empty query takes the queryString.isEmpty branch in _getSuggestions
        // and awaits _getListRecent before its setState.
        final completer = Completer<List<String>>();
        controller.text = '';

        final suggestionsBox = await buildSuggestionsBox(tester);

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: QuickSearchSuggestionList<String, String, String>(
              suggestionsBox: suggestionsBox,
              controller: controller,
              fetchRecentActionCallback: (_) => completer.future,
              animationDuration: const Duration(milliseconds: 300),
              animationStart: 0.0,
              decoration: const QuickSearchSuggestionsBoxDecoration(),
              getImmediateSuggestions: true,
              minCharsForSuggestions: 0,
            ),
          ),
        ));

        await tester.pump();

        await tester.pumpWidget(const SizedBox());

        completer.complete([]);
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'no crash when disposed while _handleDebounceTimeListener _getListRecent is pending',
      (tester) async {
        // Debounce listener path: short query (length <= minCharsForSuggestions)
        // awaits _getListRecent before its setState.
        const debounceDuration = Duration(milliseconds: 100);
        final completer = Completer<List<String>>();
        controller.text = '';

        final suggestionsBox = await buildSuggestionsBox(tester);

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: QuickSearchSuggestionList<String, String, String>(
              suggestionsBox: suggestionsBox,
              controller: controller,
              fetchRecentActionCallback: (_) => completer.future,
              animationDuration: const Duration(milliseconds: 300),
              animationStart: 0.0,
              decoration: const QuickSearchSuggestionsBoxDecoration(),
              getImmediateSuggestions: false,
              minCharsForSuggestions: 5,
              debounceDuration: debounceDuration,
            ),
          ),
        ));

        await tester.pump();

        // Trigger the debounce listener: text length 1 <= minCharsForSuggestions 5.
        controller.text = 'a';
        // Advance clock past debounce duration to fire the timer.
        await tester.pump(debounceDuration);

        // Dispose before the completer resolves.
        await tester.pumpWidget(const SizedBox());

        // Resolving must not crash (mounted check guards the setState).
        completer.complete([]);
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
