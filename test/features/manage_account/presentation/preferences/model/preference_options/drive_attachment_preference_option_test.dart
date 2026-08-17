import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/drive_attachment_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_options/drive_attachment_preference_option.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

import '../../../../../../fixtures/preference_option_fixtures.dart';

void main() {
  late FakeUpdateLocalSettingsInteractor fakeLocal;
  late DriveAttachmentPreferenceOption option;

  setUp(() {
    fakeLocal = FakeUpdateLocalSettingsInteractor();
    option = DriveAttachmentPreferenceOption(fakeLocal);
    _setDriveAttachmentEnabled(null);
    _setWorkplaceFqdn(null);
  });

  tearDown(() {
    _setDriveAttachmentEnabled(null);
    _setWorkplaceFqdn(null);
  });

  test(
    'WHEN the preferences list is rendered\n'
    'THEN drive attachment is no longer hidden behind the 7-tap reveal',
    () {
      expect(option.isExperimental, isFalse);
    },
  );

  test(
    'WHEN no drive config has been stored yet\n'
    'THEN the toggle reads as on',
    () {
      final context = preferencesContext(
        localSettings: PreferencesSetting.initial(),
      );

      expect(option.isEnabled(context), isTrue);
    },
  );

  test(
    'WHEN the user turned drive attachment off\n'
    'THEN the toggle reads as off',
    () {
      final context = preferencesContext(
        localSettings: PreferencesSetting([
          DriveAttachmentConfig(isEnabled: false),
        ]),
      );

      expect(option.isEnabled(context), isFalse);
    },
  );

  test(
    'WHEN the toggle is switched off\n'
    'THEN a disabled drive config is persisted',
    () {
      option.toggle(
        currentValue: true,
        context: preferencesContext(
          localSettings: PreferencesSetting.initial(),
        ),
      );

      expect(fakeLocal.captured, isA<DriveAttachmentConfig>());
      expect((fakeLocal.captured as DriveAttachmentConfig).isEnabled, isFalse);
    },
  );

  group('availability', () {
    test(
      'WHEN the ecosystem disables drive attachment\n'
      'THEN the setting is hidden',
      () {
        _setWorkplaceFqdn('https://workplace.example.com');
        _setDriveAttachmentEnabled(false);

        expect(option.isAvailable(preferencesContext()), isFalse);
      },
    );

    test(
      'WHEN Workplace has no FQDN\n'
      'THEN the setting is hidden',
      () {
        _setDriveAttachmentEnabled(true);
        _setWorkplaceFqdn('');

        expect(option.isAvailable(preferencesContext()), isFalse);
      },
    );

    test(
      'WHEN the ecosystem enables drive attachment and Workplace has a FQDN\n'
      'THEN the setting is visible',
      () {
        _setDriveAttachmentEnabled(true);
        _setWorkplaceFqdn('https://workplace.example.com');

        expect(option.isAvailable(preferencesContext()), isTrue);
      },
    );
  });
}

void _setDriveAttachmentEnabled(bool? enabled) => appProviderContainer
    .read(driveAttachmentEnabledProvider.notifier)
    .setEnabled(enabled);

void _setWorkplaceFqdn(String? fqdn) =>
    appProviderContainer.read(workplaceFqdnProvider.notifier).setFqdn(fqdn);
