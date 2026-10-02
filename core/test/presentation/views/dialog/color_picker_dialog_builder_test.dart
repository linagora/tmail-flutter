import 'package:core/presentation/views/dialog/color_picker_dialog_builder.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const setColorLabel = 'Set color';

void main() {
  setUp(() => Get.testMode = true);

  group('ColorPickerDialogBuilder', () {
    group('color code field', registerColorCodeFieldTests);
    group('copy', registerCopyTests);
    group('input', registerInputTests);
  });
}

void registerColorCodeFieldTests() {
  testWidgets(
    'should show the current color as #RRGGBB',
    verifyShowsHashPrefixedHex,
  );
  testWidgets(
    'should not show the Dart 0xAARRGGBB literal',
    verifyHidesDartColorLiteral,
  );
}

void registerCopyTests() {
  testWidgets(
    'should copy the current color as #RRGGBB',
    (tester) => verifyCopiedValue(tester, const Color(0xFF222222), '#222222'),
  );
  testWidgets(
    'should not copy the alpha channel of a translucent color',
    (tester) => verifyCopiedValue(tester, const Color(0x80222222), '#222222'),
  );
}

void registerInputTests() {
  testWidgets(
    'should accept a typed #RRGGBB code',
    (tester) => verifyTypedCode(tester, '#123456', const Color(0xFF123456)),
  );
  testWidgets(
    'should accept a typed short #RGB code',
    (tester) => verifyTypedCode(tester, '#123', const Color(0xFF112233)),
  );
}

Future<void> openDialog(
  WidgetTester tester,
  Color color, {
  SelectColorActionCallback? onSetColor,
}) async {
  // Desktop-sized surface: the dialog is web only, and on the default 800x600
  // surface its actions cover the color code field.
  tester.view.physicalSize = const Size(1280, 1024);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
  ColorPickerDialogBuilder(
    ValueNotifier<Color>(color),
    textActionSetColor: setColorLabel,
    setColorActionCallback: onSetColor,
  ).show();
  await tester.pumpAndSettle();
}

TextField colorCodeTextField(WidgetTester tester) => tester.widget<TextField>(
  find.descendant(
    of: find.byType(ColorCodeField),
    matching: find.byType(TextField),
  ),
);

Future<void> verifyShowsHashPrefixedHex(WidgetTester tester) async {
  await openDialog(tester, const Color(0xFF222222));

  final textField = colorCodeTextField(tester);
  expect(textField.decoration!.prefixText!.trim(), '#');
  expect(textField.controller!.text, '222222');
}

Future<void> verifyHidesDartColorLiteral(WidgetTester tester) async {
  await openDialog(tester, const Color(0xFF222222));

  expect(find.textContaining('0x'), findsNothing);
}

Future<void> verifyCopiedValue(
  WidgetTester tester,
  Color color,
  String expected,
) async {
  final copied = <String>[];
  final messenger = TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      copied.add((call.arguments as Map)['text'] as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  await openDialog(tester, color);

  await tester.tap(find.descendant(
    of: find.byType(ColorCodeField),
    matching: find.byType(IconButton),
  ));
  await tester.pump();

  expect(copied, [expected]);
}

Future<void> verifyTypedCode(
  WidgetTester tester,
  String typed,
  Color expected,
) async {
  Color? selected;
  await openDialog(
    tester,
    const Color(0xFF222222),
    onSetColor: (color) => selected = color,
  );

  await tester.enterText(
    find.descendant(
      of: find.byType(ColorCodeField),
      matching: find.byType(TextField),
    ),
    typed,
  );
  await tester.pump();
  await tester.tap(find.text(setColorLabel));
  await tester.pump();

  expect(selected, expected);
}
