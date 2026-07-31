import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_rule.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';

AttachmentUploadRequest _request({
  AttachmentUploadSizeSnapshot sizes = const AttachmentUploadSizeSnapshot(
    currentAllAttachmentBytes: 0,
    proposedAllAttachmentBytes: 0,
    currentRegularAttachmentBytes: 0,
    proposedRegularAttachmentBytes: 0,
  ),
  AttachmentUploadLimits limits = const AttachmentUploadLimits(warningLimitBytes: 1000000000),
}) {
  return AttachmentUploadRequest(sizes: sizes, limits: limits);
}

void main() {
  const rule = AttachmentSizeLimitRule();

  group('AttachmentSizeLimitRule', () {
    test('should return ValidationAllowed when neither the hard limit nor the warning threshold is exceeded', () {
      final request = _request(
        sizes: const AttachmentUploadSizeSnapshot(
          currentAllAttachmentBytes: 0,
          proposedAllAttachmentBytes: 10,
          currentRegularAttachmentBytes: 0,
          proposedRegularAttachmentBytes: 0,
        ),
        limits: const AttachmentUploadLimits(warningLimitBytes: 1000000000, hardLimitBytes: 1000));

      final result = rule.validate(request);

      expect(result, isA<ValidationAllowed>());
    });

    test('should return ValidationRejected with MaxEmailAttachmentSizeExceeded when over the hard cap', () {
      final request = _request(
        sizes: const AttachmentUploadSizeSnapshot(
          currentAllAttachmentBytes: 0,
          proposedAllAttachmentBytes: 200,
          currentRegularAttachmentBytes: 0,
          proposedRegularAttachmentBytes: 0,
        ),
        limits: const AttachmentUploadLimits(warningLimitBytes: 1000000000, hardLimitBytes: 100));

      final result = rule.validate(request) as ValidationRejected;

      expect(result.failure, isA<MaxEmailAttachmentSizeExceeded>());
      expect((result.failure as MaxEmailAttachmentSizeExceeded).maximumBytes, 100);
    });

    test('should return ValidationConfirmationRequired when only the warning threshold is exceeded', () {
      final request = _request(
        sizes: const AttachmentUploadSizeSnapshot(
          currentAllAttachmentBytes: 0,
          proposedAllAttachmentBytes: 10,
          currentRegularAttachmentBytes: 0,
          proposedRegularAttachmentBytes: 20000000,
        ),
        limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100000000));

      final result = rule.validate(request);

      expect(result, isA<ValidationConfirmationRequired>());
    });

    test('inline-only proposals never trigger the regular-attachment warning', () {
      final request = _request(
        sizes: const AttachmentUploadSizeSnapshot(
          currentAllAttachmentBytes: 0,
          proposedAllAttachmentBytes: 20000000,
          currentRegularAttachmentBytes: 0,
          proposedRegularAttachmentBytes: 0,
        ),
        limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100000000));

      final result = rule.validate(request);

      expect(result, isA<ValidationAllowed>());
    });

    test('should not re-trigger the warning for an inline-only proposal when existing regular attachments already exceed it', () {
      final request = _request(
        sizes: const AttachmentUploadSizeSnapshot(
          currentAllAttachmentBytes: 0,
          proposedAllAttachmentBytes: 20000000,
          currentRegularAttachmentBytes: 2000000,
          proposedRegularAttachmentBytes: 0,
        ),
        limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100000000));

      final result = rule.validate(request);

      expect(result, isA<ValidationAllowed>());
    });

    test('hard limit takes priority over the warning threshold', () {
      final request = _request(
        sizes: const AttachmentUploadSizeSnapshot(
          currentAllAttachmentBytes: 0,
          proposedAllAttachmentBytes: 200,
          currentRegularAttachmentBytes: 0,
          proposedRegularAttachmentBytes: 20000000,
        ),
        limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100));

      final result = rule.validate(request);

      expect(result, isA<ValidationRejected>());
    });
  });
}
