import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/compose_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  testWidgets('keeps the TMail Compose brand colors with the sidebar button',
      _testTmailComposeBrandColors);

  testWidgets('uses the resolved horizontal padding for the default width',
      _testDefaultWidthUsesResolvedPadding);

  testWidgets('keeps the design-system primary action color in dark mode',
      _testKeepsDesignSystemColorInDarkMode);

  testWidgets('clamps the default width when horizontal padding is too large',
      _testClampsDefaultWidthWithOversizedPadding);
}

Future<void> _testTmailComposeBrandColors(WidgetTester tester) async {
  var composeCalls = 0;

  await _pumpComposeButton(
    tester,
    onTapAction: () => composeCalls++,
  );

  final button = tester.widget<FilledButton>(
    find.byKey(const Key(UiKeys.composeEmailPrimaryAction)),
  );
  expect(button.style?.backgroundColor?.resolve({}), AppColor.colorComposeButton);
  expect(button.style?.foregroundColor?.resolve({}), Colors.white);

  final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
  expect(
    icon.colorFilter,
    button.style?.foregroundColor?.resolve({})?.asFilter(),
  );
  expect(button.style?.minimumSize?.resolve({}), const Size(0, 40));
  expect(
    tester.getSize(find.byType(FilledButton)),
    const Size(ResponsiveUtils.sidebarMenuWidth - 32, 40),
  );
  expect(tester.getSize(find.byType(SvgPicture)), const Size(12, 12));

  await tester.tap(find.byKey(const Key(UiKeys.composeEmailPrimaryAction)));
  expect(composeCalls, 1);
}

Future<void> _testDefaultWidthUsesResolvedPadding(WidgetTester tester) async {
  const padding = EdgeInsetsDirectional.only(
    start: 12,
    end: 28,
    top: 16,
    bottom: 8,
  );

  await _pumpComposeButton(tester, padding: padding);

  expect(
    tester.getSize(find.byType(FilledButton)),
    const Size(ResponsiveUtils.sidebarMenuWidth - 40, 40),
  );
}

Future<void> _testKeepsDesignSystemColorInDarkMode(
  WidgetTester tester,
) async {
  await _pumpComposeButton(tester, brightness: Brightness.dark);

  final buttonFinder = find.byKey(
    const Key(UiKeys.composeEmailPrimaryAction),
  );
  final button = tester.widget<FilledButton>(buttonFinder);
  final expectedStyle = LinagoraSidebarButtonStyles.primaryAction(
    tester.element(buttonFinder),
  );

  expect(
    button.style?.backgroundColor?.resolve({}),
    expectedStyle.backgroundColor?.resolve({}),
  );
}

Future<void> _testClampsDefaultWidthWithOversizedPadding(
  WidgetTester tester,
) async {
  const padding = EdgeInsetsDirectional.only(
    start: ResponsiveUtils.sidebarMenuWidth,
    end: 1,
  );

  await _pumpComposeButton(tester, padding: padding);

  expect(
    tester.widget<LinagoraSidebarPrimaryAction>(
      find.byType(LinagoraSidebarPrimaryAction),
    ).width,
    0,
  );
}

Future<void> _pumpComposeButton(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  EdgeInsetsGeometry? padding,
  VoidCallback? onTapAction,
}) async {
  await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Theme(
        data: ThemeUtils.buildAppTheme(context).copyWith(
          brightness: brightness,
          visualDensity: VisualDensity.compact,
        ),
        child: child!,
      ),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: Scaffold(
        body: ComposeButtonWidget(
          imagePaths: ImagePaths(),
          onTapAction: onTapAction ?? () {},
          padding: padding,
        ),
      ),
    ));
  await tester.pump();
}
