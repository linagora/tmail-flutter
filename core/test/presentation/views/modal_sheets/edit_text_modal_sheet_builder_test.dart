import 'package:core/presentation/views/modal_sheets/edit_text_modal_sheet_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  const invalidNameError = 'Invalid name';

  Future<List<String>> pumpModalSheet(WidgetTester tester) async {
    final submittedValues = <String>[];

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => (EditTextModalSheetBuilder()
                ..key(const Key('rename_mailbox_dialog'))
                ..title('Rename folder')
                ..cancelText('Cancel')
                ..onConfirmAction('Rename', submittedValues.add)
                ..setErrorString(
                  (value) => value.contains('.') ? invalidNameError : null,
                )
                ..setTextController(TextEditingController(text: 'Inbox')))
                .show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    return submittedValues;
  }

  group('EditTextModalSheetBuilder', () {
    testWidgets(
      'should validate on confirm when it is tapped before the debounced validation runs',
      (tester) async {
        final submittedValues = await pumpModalSheet(tester);

        await tester.enterText(find.byType(TextField), 'a.b');
        await tester.tap(find.text('RENAME'));
        await tester.pump();

        expect(submittedValues, isEmpty);
        expect(find.text(invalidNameError), findsOneWidget);
        expect(tester.widget<Text>(find.text(invalidNameError)).maxLines, 3);
        expect(find.byKey(const Key('rename_mailbox_dialog')), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets('should submit a valid value on confirm', (tester) async {
      final submittedValues = await pumpModalSheet(tester);

      await tester.enterText(find.byType(TextField), 'a/b');
      await tester.tap(find.text('RENAME'));
      await tester.pumpAndSettle();

      expect(submittedValues, ['a/b']);
      expect(find.byKey(const Key('rename_mailbox_dialog')), findsNothing);
    });
  });
}
