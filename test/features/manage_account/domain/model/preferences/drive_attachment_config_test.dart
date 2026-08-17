import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/drive_attachment_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

void main() {
  _testDefaultValue();
  _testSerialization();
  _testPreferencesSettingAccessor();
}

void _testDefaultValue() {
  group('DriveAttachmentConfig default', () {
    test(
      'WHEN no value is supplied\n'
      'THEN drive attachment is enabled',
      () {
        expect(DriveAttachmentConfig().isEnabled, isTrue);
        expect(DriveAttachmentConfig.initial().isEnabled, isTrue);
      },
    );

    test(
      'WHEN stored json has no isEnabled key\n'
      'THEN drive attachment falls back to enabled',
      () {
        expect(DriveAttachmentConfig.fromJson({}).isEnabled, isTrue);
      },
    );
  });
}

void _testSerialization() {
  group('DriveAttachmentConfig serialization', () {
    test(
      'WHEN the user explicitly opted out\n'
      'THEN the stored value wins over the new default',
      () {
        expect(
          DriveAttachmentConfig.fromJson({'isEnabled': false}).isEnabled,
          isFalse,
        );
      },
    );

    test(
      'WHEN a config is serialized and read back\n'
      'THEN isEnabled survives the round trip',
      () {
        final disabled = DriveAttachmentConfig(isEnabled: false);

        expect(DriveAttachmentConfig.fromJson(disabled.toJson()), disabled);
      },
    );
  });
}

void _testPreferencesSettingAccessor() {
  group('PreferencesSetting.driveAttachmentConfig', () {
    test(
      'WHEN settings are freshly initialized\n'
      'THEN drive attachment is enabled',
      () {
        expect(
          PreferencesSetting.initial().driveAttachmentConfig.isEnabled,
          isTrue,
        );
      },
    );

    test(
      'WHEN an existing install stores other configs but no drive config\n'
      'THEN drive attachment defaults to enabled',
      () {
        final settings = PreferencesSetting([ThreadDetailConfig(isEnabled: true)]);

        expect(settings.driveAttachmentConfig.isEnabled, isTrue);
      },
    );

    test(
      'WHEN a stored drive config disables the feature\n'
      'THEN the stored value is returned',
      () {
        final settings = PreferencesSetting([
          DriveAttachmentConfig(isEnabled: false),
        ]);

        expect(settings.driveAttachmentConfig.isEnabled, isFalse);
      },
    );
  });
}
