
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';

abstract interface class AttachmentValidationFeedback {
  Future<void> showFailure(AttachmentUploadFailure failure);
  Future<bool> confirmAll(List<AttachmentUploadPrompt> prompts);
}
