
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_upload_recovery.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback.dart';

final class AttachmentUploadGate {
  final AttachmentUploadValidator _validator;

  const AttachmentUploadGate(this._validator);

  Future<bool> permits({
    required AttachmentUploadRequest request,
    required AttachmentValidationFeedback? Function() feedbackFactory,
    AttachmentUploadRecovery? Function()? recoveryFactory,
  }) async {
    switch (_validator.validate(request)) {
      case ValidationAllowed():
        return true;
      case ValidationRejected(:final failure):
        // Inline-only batches (e.g. an oversize pasted screenshot) skip recovery.
        final recovery = request.regularFiles.isNotEmpty ? recoveryFactory?.call() : null;
        if (recovery != null && await _recovered(recovery, failure, request)) return false;
        final feedback = feedbackFactory();
        if (feedback == null) return false;
        await feedback.showFailure(failure);
        return false;
      case ValidationConfirmationRequired(:final prompts):
        final feedback = feedbackFactory();
        if (feedback == null) return false;
        return feedback.confirmAll(prompts);
    }
  }

  Future<bool> _recovered(
    AttachmentUploadRecovery recovery,
    AttachmentUploadFailure failure,
    AttachmentUploadRequest request,
  ) async {
    try {
      return await recovery.recover(failure, request);
    } catch (e) {
      logError('AttachmentUploadGate::_recovered: $e');
      return false;
    }
  }
}
