
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_pipeline.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_rule.dart';

final class AttachmentUploadRequest {
  final AttachmentUploadSizeSnapshot sizes;
  final AttachmentUploadLimits limits;

  const AttachmentUploadRequest({required this.sizes, required this.limits});
}

typedef AttachmentUploadDecision = ValidationDecision<AttachmentUploadFailure, AttachmentUploadPrompt>;
typedef AttachmentUploadRule = ValidationRule<AttachmentUploadRequest, AttachmentUploadFailure, AttachmentUploadPrompt>;
typedef AttachmentUploadValidator = ValidationPipeline<AttachmentUploadRequest, AttachmentUploadFailure, AttachmentUploadPrompt>;
