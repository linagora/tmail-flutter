import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_rule.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';

AttachmentUploadRequest _request({
  required AttachmentUploadSizeSnapshot sizes,
  required AttachmentUploadLimits limits,
}) {
  return AttachmentUploadRequest(sizes: sizes, limits: limits);
}

class _RuleCase {
  const _RuleCase({
    required this.description,
    required this.sizes,
    required this.limits,
    required this.verify,
  });

  final String description;
  final AttachmentUploadSizeSnapshot sizes;
  final AttachmentUploadLimits limits;
  final void Function(ValidationDecision result) verify;
}

final _cases = [
  _RuleCase(
    description: 'should return ValidationAllowed when neither the hard limit nor the warning threshold is exceeded',
    sizes: const AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: 10,
      currentRegularAttachmentBytes: 0,
      proposedRegularAttachmentBytes: 0,
    ),
    limits: const AttachmentUploadLimits(warningLimitBytes: 1000000000, hardLimitBytes: 1000),
    verify: (result) => expect(result, isA<ValidationAllowed>()),
  ),
  _RuleCase(
    description: 'should return ValidationRejected with MaxEmailAttachmentSizeExceeded when over the hard cap',
    sizes: const AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: 200,
      currentRegularAttachmentBytes: 0,
      proposedRegularAttachmentBytes: 0,
    ),
    limits: const AttachmentUploadLimits(warningLimitBytes: 1000000000, hardLimitBytes: 100),
    verify: (result) {
      final rejected = result as ValidationRejected;
      expect(rejected.failure, isA<MaxEmailAttachmentSizeExceeded>());
      expect((rejected.failure as MaxEmailAttachmentSizeExceeded).maximumBytes, 100);
    },
  ),
  _RuleCase(
    description: 'should return ValidationConfirmationRequired when only the warning threshold is exceeded',
    sizes: const AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: 10,
      currentRegularAttachmentBytes: 0,
      proposedRegularAttachmentBytes: 20000000,
    ),
    limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100000000),
    verify: (result) => expect(result, isA<ValidationConfirmationRequired>()),
  ),
  _RuleCase(
    description: 'inline-only proposals never trigger the regular-attachment warning',
    sizes: const AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: 20000000,
      currentRegularAttachmentBytes: 0,
      proposedRegularAttachmentBytes: 0,
    ),
    limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100000000),
    verify: (result) => expect(result, isA<ValidationAllowed>()),
  ),
  _RuleCase(
    description: 'should not re-trigger the warning for an inline-only proposal when existing regular attachments already exceed it',
    sizes: const AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: 20000000,
      currentRegularAttachmentBytes: 2000000,
      proposedRegularAttachmentBytes: 0,
    ),
    limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100000000),
    verify: (result) => expect(result, isA<ValidationAllowed>()),
  ),
  _RuleCase(
    description: 'hard limit takes priority over the warning threshold',
    sizes: const AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: 200,
      currentRegularAttachmentBytes: 0,
      proposedRegularAttachmentBytes: 20000000,
    ),
    limits: const AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: 100),
    verify: (result) => expect(result, isA<ValidationRejected>()),
  ),
];

void main() {
  const rule = AttachmentSizeLimitRule();

  group('AttachmentSizeLimitRule', () {
    for (final ruleCase in _cases) {
      test(ruleCase.description, () {
        final request = _request(sizes: ruleCase.sizes, limits: ruleCase.limits);

        final result = rule.validate(request);

        ruleCase.verify(result);
      });
    }
  });
}
