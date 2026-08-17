import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/default_switch_icon_widget.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/drive_attachment_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_options/drive_attachment_preference_option.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/widgets/preferences_option_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/experimental_preferences_revealed_provider.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../../fixtures/preference_option_fixtures.dart';

/// [revealed] is pinned to false throughout, so these cover what a plain user
/// sees without ever triggering the 7-tap reveal: the drive row is rendered,
/// and it is already switched on.
void main() {
  late PreferenceOption option;

  /// Matches only the option item's own switch, since the widget forwards its
  /// key down to the inner [SvgPicture] as well.
  Finder switchWithKey(String key) => find.byWidgetPredicate(
        (widget) =>
            widget is DefaultSwitchIconWidget && widget.key == ValueKey(key),
      );

  Future<void> pumpOptionItem(
    WidgetTester tester, {
    required PreferencesSetting localSettings,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          experimentalPreferencesRevealedProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.defaultLocale,
          home: Scaffold(
            body: PreferencesOptionItem(
              imagePaths: ImagePaths(),
              option: option,
              preferencesContext: preferencesContext(localSettings: localSettings),
              onTapPreferencesOptionAction: (_, __) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    option = DriveAttachmentPreferenceOption(FakeUpdateLocalSettingsInteractor());
  });

  testWidgets(
    'WHEN experimental preferences were never revealed\n'
    'THEN the drive attachment row is still rendered',
    (tester) async {
      await pumpOptionItem(tester, localSettings: PreferencesSetting.initial());

      expect(find.byType(DefaultSwitchIconWidget), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN no drive preference was ever stored\n'
    'THEN the switch is rendered in the on state',
    (tester) async {
      await pumpOptionItem(tester, localSettings: PreferencesSetting.initial());

      expect(switchWithKey('setting_option_switch_on'), findsOneWidget);
      expect(switchWithKey('setting_option_switch_off'), findsNothing);
    },
  );

  testWidgets(
    'WHEN the user previously turned drive attachment off\n'
    'THEN the switch is rendered in the off state',
    (tester) async {
      await pumpOptionItem(
        tester,
        localSettings: PreferencesSetting([DriveAttachmentConfig(isEnabled: false)]),
      );

      expect(switchWithKey('setting_option_switch_off'), findsOneWidget);
      expect(switchWithKey('setting_option_switch_on'), findsNothing);
    },
  );
}
