
import 'package:model/upload/file_info.dart';
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

  /// Empty when built from byte counts only (re-attaching an uploaded attachment).
  final List<FileInfo> files;

  AttachmentUploadRequest({
    required this.sizes,
    required this.limits,
    Iterable<FileInfo> files = const [],
  }) : files = List.unmodifiable(files);
}

typedef AttachmentUploadDecision = ValidationDecision<AttachmentUploadFailure, AttachmentUploadPrompt>;
typedef AttachmentUploadRule = ValidationRule<AttachmentUploadRequest, AttachmentUploadFailure, AttachmentUploadPrompt>;
typedef AttachmentUploadValidator = ValidationPipeline<AttachmentUploadRequest, AttachmentUploadFailure, AttachmentUploadPrompt>;
