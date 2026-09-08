import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

void main() {
  group('AppConfig.isDriveAttachmentEnabled', () {
    tearDown(() => dotenv.clean());

    test('false when env is not loaded', () {
      dotenv.clean();
      expect(AppConfig.isDriveAttachmentEnabled, isFalse);
    });

    test('false when key is absent', () {
      dotenv.testLoad(mergeWith: {});
      expect(AppConfig.isDriveAttachmentEnabled, isFalse);
    });

    test('false when key is empty', () {
      dotenv.testLoad(mergeWith: {'DRIVE_ATTACHMENT_ENABLED': ''});
      expect(AppConfig.isDriveAttachmentEnabled, isFalse);
    });

    test('false when key is false', () {
      dotenv.testLoad(mergeWith: {'DRIVE_ATTACHMENT_ENABLED': 'false'});
      expect(AppConfig.isDriveAttachmentEnabled, isFalse);
    });

    test('true when key is true', () {
      dotenv.testLoad(mergeWith: {'DRIVE_ATTACHMENT_ENABLED': 'true'});
      expect(AppConfig.isDriveAttachmentEnabled, isTrue);
    });
  });
}
