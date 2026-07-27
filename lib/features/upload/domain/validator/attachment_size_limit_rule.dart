
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_policy.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';

final class AttachmentSizeLimitRule implements AttachmentUploadRule {
  const AttachmentSizeLimitRule();

  @override
  AttachmentUploadDecision validate(AttachmentUploadRequest request) {
    final hardLimit = request.limits.hardLimitBytes;
    if (AttachmentSizeLimitPolicy.isExceededMaxSizeAttachmentsPerEmail(
        allAttachmentBytes: request.sizes.allAttachmentBytes,
        hardLimitBytes: hardLimit)) {
      return ValidationRejected(MaxEmailAttachmentSizeExceeded(hardLimit!));
    }

    if (AttachmentSizeLimitPolicy.isExceededWarningAttachmentFileSizeInComposer(
        regularAttachmentBytes: request.sizes.regularAttachmentBytes,
        warningLimitBytes: request.limits.warningLimitBytes)) {
      return ValidationConfirmationRequired(const [LargeRegularAttachmentWarning()]);
    }

    return const ValidationAllowed();
  }
}
