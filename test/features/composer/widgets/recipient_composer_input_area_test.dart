import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

const _prefix = PrefixEmailAddress.to;
const _fieldWidth = 360.0;

void main() {
  setUpAll(() => Get.put(ResponsiveUtils()));
  tearDownAll(Get.reset);

  group('RecipientComposerWidget input area after chips test', () {
    testWidgets(
      'WHEN chips leave less room than the minimum input width AND the field is unfocused\n'
      'THEN the input SHOULD stay on its own line below the chips AND tapping it SHOULD focus it',
      _expectInputOnOwnLineIsFocusable,
    );

    testWidgets(
      'WHEN the last line still has room for the input\n'
      'THEN the input SHOULD NOT move to a new line',
      _expectInputStaysOnChipLine,
    );

    testWidgets(
      'WHEN tapping the blank space after a chip on a full line\n'
      'THEN the input SHOULD get focus',
      _expectBlankSpaceTapFocusesInput,
    );

    testWidgets(
      'WHEN tapping the delete icon of a chip\n'
      'THEN the chip SHOULD be removed AND the input SHOULD NOT get focus',
      _expectChipDeleteDoesNotFocusInput,
    );
  });
}

final _chipFinder = find.byType(RecipientTagItemWidget);

final _inputFinder = find.descendant(
  of: find.byType(TagEditor<SuggestionEmailAddress>),
  matching: find.byType(TextField),
);

Future<void> _pumpRecipientField(
  WidgetTester tester, {
  required double width,
  required int chipCount,
  FocusNode? focusNode,
}) async {
  await tester.pumpWidget(GetMaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: AlignmentDirectional.topStart,
        child: SizedBox(
          width: width,
          child: RecipientComposerWidget(
            prefix: _prefix,
            listEmailAddress: List.generate(
              chipCount,
              (index) => EmailAddress(null, 'recipient${index + 1}@example.com'),
            ),
            imagePaths: ImagePaths(),
            maxWidth: _fieldWidth,
            focusNode: focusNode,
          ),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// Returns the field width at which one chip leaves exactly [leftOverWidth]
/// free on its line.
Future<double> _fieldWidthLeaving(
  WidgetTester tester, {
  required double leftOverWidth,
}) async {
  await _pumpRecipientField(tester, width: _fieldWidth, chipCount: 1);
  final chipWidth = tester.getSize(_chipFinder).width;
  final editorWidth = tester.getSize(find.byType(TagEditor<SuggestionEmailAddress>)).width;
  // TagEditor reads its focus node only once, so drop this tree before the
  // caller pumps the field again.
  await tester.pumpWidget(const SizedBox.shrink());
  return _fieldWidth - editorWidth + chipWidth + leftOverWidth;
}

FocusNode _createFocusNode() {
  final focusNode = FocusNode();
  addTearDown(focusNode.dispose);
  return focusNode;
}

Future<void> _expectInputOnOwnLineIsFocusable(WidgetTester tester) async {
  final focusNode = _createFocusNode();
  final width = await _fieldWidthLeaving(tester, leftOverWidth: 10);
  await _pumpRecipientField(tester, width: width, chipCount: 1, focusNode: focusNode);

  final chipRect = tester.getRect(_chipFinder);
  final inputRect = tester.getRect(_inputFinder);
  expect(focusNode.hasFocus, isFalse);
  expect(inputRect.top, greaterThanOrEqualTo(chipRect.bottom));
  expect(inputRect.height, greaterThan(0));

  await tester.tapAt(inputRect.center);
  await tester.pumpAndSettle();

  expect(focusNode.hasFocus, isTrue);
}

Future<void> _expectInputStaysOnChipLine(WidgetTester tester) async {
  final width = await _fieldWidthLeaving(tester, leftOverWidth: 100);
  await _pumpRecipientField(tester, width: width, chipCount: 1);

  final chipRect = tester.getRect(_chipFinder);
  final inputRect = tester.getRect(_inputFinder);
  expect(inputRect.top, lessThan(chipRect.bottom));
  expect(inputRect.left, greaterThanOrEqualTo(chipRect.right));
}

Future<void> _expectBlankSpaceTapFocusesInput(WidgetTester tester) async {
  final focusNode = _createFocusNode();
  final width = await _fieldWidthLeaving(tester, leftOverWidth: 10);
  await _pumpRecipientField(tester, width: width, chipCount: 2, focusNode: focusNode);

  final firstChipRect = tester.getRect(_chipFinder.first);
  await tester.tapAt(Offset(firstChipRect.right + 5, firstChipRect.center.dy));
  await tester.pumpAndSettle();

  expect(focusNode.hasFocus, isTrue);
}

Future<void> _expectChipDeleteDoesNotFocusInput(WidgetTester tester) async {
  final focusNode = _createFocusNode();
  await _pumpRecipientField(tester, width: _fieldWidth, chipCount: 1, focusNode: focusNode);

  await tester.tap(find.byKey(Key('delete_icon_recipient_tag_item_${_prefix.name}_0')));
  await tester.pumpAndSettle();

  expect(_chipFinder, findsNothing);
  expect(focusNode.hasFocus, isFalse);
}
