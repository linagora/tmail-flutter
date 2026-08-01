import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_policy.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

void main() {
  group('AttachmentSizeLimitPolicy.isExceededMaxSizeAttachmentsPerEmail', () {
    test('should return false when hardLimitBytes is null (unlimited)', () {
      final result = AttachmentSizeLimitPolicy.isExceededMaxSizeAttachmentsPerEmail(
        allAttachmentBytes: 2000000000,
        hardLimitBytes: null);

      expect(result, isFalse);
    });

    test('should return false when total size is exactly at the cap', () {
      final result = AttachmentSizeLimitPolicy.isExceededMaxSizeAttachmentsPerEmail(
        allAttachmentBytes: 100,
        hardLimitBytes: 100);

      expect(result, isFalse);
    });

    test('should return true when total size exceeds the cap', () {
      final result = AttachmentSizeLimitPolicy.isExceededMaxSizeAttachmentsPerEmail(
        allAttachmentBytes: 101,
        hardLimitBytes: 100);

      expect(result, isTrue);
    });
  });

  group('AttachmentSizeLimitPolicy.isExceededWarningAttachmentFileSizeInComposer', () {
    const maxWarningBytes = AppConfig.warningAttachmentFileSizeInMegabytes * 1024 * 1024;

    test('should return false when total size is exactly at the warning threshold', () {
      final result = AttachmentSizeLimitPolicy.isExceededWarningAttachmentFileSizeInComposer(
        regularAttachmentBytes: maxWarningBytes,
        warningLimitBytes: maxWarningBytes);

      expect(result, isFalse);
    });

    test('should return true when total size exceeds the warning threshold', () {
      final result = AttachmentSizeLimitPolicy.isExceededWarningAttachmentFileSizeInComposer(
        regularAttachmentBytes: maxWarningBytes + 1,
        warningLimitBytes: maxWarningBytes);

      expect(result, isTrue);
    });
  });
}
