import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const invalidNameError = 'Invalid name';

  String? validateName(String value) =>
      value.contains('.') ? invalidNameError : null;

  Future<List<String>> pumpDialog(WidgetTester tester) async {
    final submittedValues = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditTextDialogBuilder(
            title: 'Rename folder',
            value: 'Inbox',
            positiveText: 'Rename',
            negativeText: 'Cancel',
            onPositiveButtonAction: submittedValues.add,
            onInputErrorChanged: validateName,
          ),
        ),
      ),
    );

    return submittedValues;
  }

  group('EditTextDialogBuilder', () {
    testWidgets(
      'should validate on confirm when it is tapped before the debounced validation runs',
      (tester) async {
        final submittedValues = await pumpDialog(tester);

        await tester.enterText(find.byType(TextField), 'a.b');
        await tester.tap(find.text('Rename'));
        await tester.pump();

        expect(submittedValues, isEmpty);
        expect(find.text(invalidNameError), findsOneWidget);
        expect(tester.widget<Text>(find.text(invalidNameError)).maxLines, 3);

        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets('should submit a valid value on confirm', (tester) async {
      final submittedValues = await pumpDialog(tester);

      await tester.enterText(find.byType(TextField), 'a/b');
      await tester.tap(find.text('Rename'));
      await tester.pump();

      expect(submittedValues, ['a/b']);
      expect(find.text(invalidNameError), findsNothing);
    });
  });
}
