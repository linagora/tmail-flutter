import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_rule.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';

AttachmentUploadRequest _request({
  int proposedAllAttachmentBytes = 0,
  int proposedRegularAttachmentBytes = 0,
  int? hardLimitBytes,
  int warningLimitBytes = 1000000000,
}) {
  return AttachmentUploadRequest(
    sizes: AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: proposedAllAttachmentBytes,
      currentRegularAttachmentBytes: 0,
      proposedRegularAttachmentBytes: proposedRegularAttachmentBytes,
    ),
    limits: AttachmentUploadLimits(warningLimitBytes: warningLimitBytes, hardLimitBytes: hardLimitBytes),
  );
}

void main() {
  const rule = AttachmentSizeLimitRule();

  group('AttachmentSizeLimitRule', () {
    test('should return ValidationAllowed when neither the hard limit nor the warning threshold is exceeded', () {
      final request = _request(proposedAllAttachmentBytes: 10, hardLimitBytes: 1000);

      final result = rule.validate(request);

      expect(result, isA<ValidationAllowed>());
    });

    test('should return ValidationRejected with MaxEmailAttachmentSizeExceeded when over the hard cap', () {
      final request = _request(proposedAllAttachmentBytes: 200, hardLimitBytes: 100);

      final result = rule.validate(request) as ValidationRejected;

      expect(result.failure, isA<MaxEmailAttachmentSizeExceeded>());
      expect((result.failure as MaxEmailAttachmentSizeExceeded).maximumBytes, 100);
    });

    test('should return ValidationConfirmationRequired when only the warning threshold is exceeded', () {
      final request = _request(
        proposedAllAttachmentBytes: 10,
        proposedRegularAttachmentBytes: 20000000,
        hardLimitBytes: 100000000,
        warningLimitBytes: 1000000);

      final result = rule.validate(request);

      expect(result, isA<ValidationConfirmationRequired>());
    });

    test('inline-only proposals never trigger the regular-attachment warning', () {
      final request = _request(
        proposedAllAttachmentBytes: 20000000,
        proposedRegularAttachmentBytes: 0,
        hardLimitBytes: 100000000,
        warningLimitBytes: 1000000);

      final result = rule.validate(request);

      expect(result, isA<ValidationAllowed>());
    });

    test('hard limit takes priority over the warning threshold', () {
      final request = _request(
        proposedAllAttachmentBytes: 200,
        proposedRegularAttachmentBytes: 20000000,
        hardLimitBytes: 100,
        warningLimitBytes: 1000000);

      final result = rule.validate(request);

      expect(result, isA<ValidationRejected>());
    });
  });
}
