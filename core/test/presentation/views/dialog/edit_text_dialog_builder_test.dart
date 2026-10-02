import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditTextDialogBuilder', () {
    const initialError = 'Incorrect password';

    Future<List<String>> pumpDialog(
      WidgetTester tester, {
      bool obscureText = false,
      String? error,
    }) async {
      final submittedValues = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EditTextDialogBuilder(
            title: 'Title',
            value: '',
            positiveText: 'Open',
            negativeText: 'Cancel',
            obscureText: obscureText,
            initialError: error,
            onPositiveButtonAction: submittedValues.add,
          ),
        ),
      ));
      return submittedValues;
    }

    testWidgets('should not obscure text by default', (tester) async {
      await pumpDialog(tester);

      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
    });

    testWidgets('should obscure text when obscureText is true', (tester) async {
      await pumpDialog(tester, obscureText: true);

      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    });

    testWidgets('should display initial error until the text changes', (tester) async {
      await pumpDialog(tester, error: initialError);
      expect(find.text(initialError), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'secret');
      await tester.pump();

      expect(find.text(initialError), findsNothing);
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('should allow submitting while initial error is displayed', (tester) async {
      final submittedValues = await pumpDialog(tester, error: initialError);

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(submittedValues, ['']);
    });
  });
}
