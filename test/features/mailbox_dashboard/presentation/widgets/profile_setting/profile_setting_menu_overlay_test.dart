import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_menu_overlay.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

Future<AppLocalizations> pumpMenuOverlay(
  WidgetTester tester, {
  required bool isInsideCozy,
  OnProfileSettingActionTypeClick? onProfileSettingActionTypeClick,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        insideCozyProvider.overrideWith((ref) => isInsideCozy),
      ],
      child: MaterialApp(
        locale: LocalizationService.defaultLocale,
        supportedLocales: LocalizationService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: ProfileSettingMenuOverlay(
            ownEmailAddress: 'alice@domain.tld',
            settingActionTypes: ProfileSettingActionType.values,
            imagePaths: ImagePaths(),
            onCopyButtonAction: () {},
            onProfileSettingActionTypeClick:
                onProfileSettingActionTypeClick ?? (_) {},
            onCloseProfileSettingMenuAction: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return AppLocalizations.of(
    tester.element(find.byType(ProfileSettingMenuOverlay)),
  );
}

void main() {
  group('ProfileSettingMenuOverlay', () {
    testWidgets(
      'should show manage account and sign out outside Cozy',
      (tester) async {
        final appLocalizations =
            await pumpMenuOverlay(tester, isInsideCozy: false);

        expect(find.text(appLocalizations.manage_account), findsOneWidget);
        expect(find.text(appLocalizations.sign_out), findsOneWidget);
      },
    );

    testWidgets(
      'should show only manage account inside Cozy, since Workplace owns sign out',
      (tester) async {
        final appLocalizations =
            await pumpMenuOverlay(tester, isInsideCozy: true);

        expect(find.text(appLocalizations.manage_account), findsOneWidget);
        expect(find.text(appLocalizations.sign_out), findsNothing);
      },
    );

    testWidgets(
      'should emit sign out exactly once when it is tapped outside Cozy',
      (tester) async {
        final clickedActionTypes = <ProfileSettingActionType>[];
        final appLocalizations = await pumpMenuOverlay(
          tester,
          isInsideCozy: false,
          onProfileSettingActionTypeClick: clickedActionTypes.add,
        );

        await tester.tap(find.text(appLocalizations.sign_out));
        await tester.pump();

        expect(clickedActionTypes, [ProfileSettingActionType.signOut]);
      },
    );
  });
}
