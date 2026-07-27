
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback.dart';

final class AttachmentUploadGate {
  final AttachmentUploadValidator _validator;

  const AttachmentUploadGate(this._validator);

  Future<bool> permits({
    required AttachmentUploadRequest request,
    required AttachmentValidationFeedback? Function() feedbackFactory,
  }) async {
    switch (_validator.validate(request)) {
      case ValidationAllowed():
        return true;
      case ValidationRejected(:final failure):
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
}
