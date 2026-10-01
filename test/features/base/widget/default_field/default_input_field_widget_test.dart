import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';

void main() {
  const shortError = 'Invalid';
  const longError = 'Folder name cannot start with "#" nor contain ".", "%", "*" or line breaks';

  Future<void> pumpField(
    WidgetTester tester, {
    String? errorText,
    int? errorMaxLines,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: DefaultInputFieldWidget(
                textEditingController: TextEditingController(text: 'QA.dot'),
                errorText: errorText,
                errorMaxLines: errorMaxLines,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double fieldHeight(WidgetTester tester) =>
      tester.getSize(find.byType(InputDecorator)).height;

  double inputTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(EditableText)).dy -
      tester.getTopLeft(find.byType(InputDecorator)).dy;

  group('DefaultInputFieldWidget', () {
    testWidgets('should keep the error on one line by default', (tester) async {
      await pumpField(tester, errorText: longError);

      expect(fieldHeight(tester), 60);
      expect(tester.widget<Text>(find.text(longError)).maxLines, isNull);
    });

    testWidgets(
      'should keep the default layout for a one-line error when errorMaxLines is set',
      (tester) async {
        await pumpField(tester, errorText: shortError);
        final defaultHeight = fieldHeight(tester);
        final defaultInputTop = inputTop(tester);

        await pumpField(tester, errorText: shortError, errorMaxLines: 3);

        expect(fieldHeight(tester), defaultHeight);
        expect(inputTop(tester), defaultInputTop);
      },
    );

    testWidgets(
      'should keep the default layout without an error when errorMaxLines is set',
      (tester) async {
        await pumpField(tester);
        final defaultHeight = fieldHeight(tester);
        final defaultInputTop = inputTop(tester);

        await pumpField(tester, errorMaxLines: 3);

        expect(fieldHeight(tester), defaultHeight);
        expect(inputTop(tester), defaultInputTop);
      },
    );

    testWidgets('should wrap a long error on up to errorMaxLines lines',
        (tester) async {
      await pumpField(tester, errorText: longError, errorMaxLines: 3);

      expect(tester.widget<Text>(find.text(longError)).maxLines, 3);
      expect(fieldHeight(tester), 96);
    });
  });
}
