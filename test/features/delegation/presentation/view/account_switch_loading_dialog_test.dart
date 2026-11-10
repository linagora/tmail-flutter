import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/account_switch_loading_dialog.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

bool _spanTreeHasBoldTarget(InlineSpan root, String target) {
  if (root is! TextSpan) return false;
  final weight = root.style?.fontWeight;
  final isBold =
      weight == FontWeight.w700 || weight == FontWeight.bold;
  if (root.text == target && isBold) return true;
  final children = root.children;
  if (children == null) return false;
  return children.any((child) => _spanTreeHasBoldTarget(child, target));
}

void main() {
  const owner = 'alice@example.com';

  Future<void> pumpDialog(
    WidgetTester tester, {
    bool returningToMine = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Scaffold(
          body: AccountSwitchLoadingDialog(
            ownerName: owner,
            returningToMine: returningToMine,
            onCancel: () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  test('openingMessageSpans bolds only the target name', () {
    const base = TextStyle(fontSize: 16, color: Color(0xFF424244));
    final message = AppLocalizations().openingOwnerMailbox(owner);
    final spans = AccountSwitchLoadingDialog.openingMessageSpans(
      message: message,
      ownerName: owner,
      baseStyle: base,
    );

    expect(spans, hasLength(3));
    expect((spans[0] as TextSpan).text, 'Opening ');
    expect((spans[0] as TextSpan).style?.fontWeight, isNull);
    expect((spans[1] as TextSpan).text, owner);
    expect((spans[1] as TextSpan).style?.fontWeight, FontWeight.w700);
    expect((spans[2] as TextSpan).text, "'s mailbox…");
    expect((spans[2] as TextSpan).style?.fontWeight, isNull);
  });

  testWidgets('renders Text.rich with a bold span for the target account',
      (tester) async {
    await pumpDialog(tester);

    expect(
      find.byKey(const ValueKey(UiKeys.accountSwitchLoadingDialog)),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey(UiKeys.accountSwitchLoadingCancel)),
      findsOneWidget,
    );

    final message = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.textSpan != null &&
          _spanTreeHasBoldTarget(widget.textSpan!, owner),
    );
    expect(message, findsOneWidget);

    final text = tester.widget<Text>(message);
    expect(text.textSpan, isA<TextSpan>());
    expect(_spanTreeHasBoldTarget(text.textSpan!, owner), isTrue);
  });

  testWidgets('uses return-to-mine copy without bolding an owner address',
      (tester) async {
    await pumpDialog(tester, returningToMine: true);

    expect(find.text(AppLocalizations().openingYourMailbox), findsOneWidget);
    expect(find.textContaining(owner), findsNothing);
  });
}
