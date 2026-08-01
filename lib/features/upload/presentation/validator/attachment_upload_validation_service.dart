import 'package:flutter/widgets.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_policy.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_rule.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request_factory.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_state_source.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_upload_gate.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback_impl.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef AttachmentValidationFeedbackBuilder = AttachmentValidationFeedback Function(BuildContext context);

/// Single entry point for every attachment upload call site: hand it what the
/// user wants to attach plus the action to run once allowed, and it builds the
/// validation request, runs the rules and shows the resulting dialogs.
///
/// This is a UX guard, not an enforcement boundary. Each request is evaluated
/// against the byte totals [_stateSource] reports at call time. Two attachment
/// actions can overlap while a confirmation dialog is awaiting the user, in
/// which case neither sees the other's bytes and together they may exceed the
/// server limit. That is accepted: the composer's send guard rejects it before
/// sending, and the server enforces the limit regardless.
class AttachmentUploadValidationService {
  static const AttachmentUploadRequestFactory _requestFactory = AttachmentUploadRequestFactory();

  final AttachmentUploadStateSource _stateSource;
  final AttachmentUploadGate _gate;
  final AttachmentValidationFeedbackBuilder _feedbackBuilder;

  AttachmentUploadValidationService({
    required AttachmentUploadStateSource stateSource,
    AttachmentUploadValidator? validator,
    AttachmentValidationFeedbackBuilder? feedbackBuilder,
  })  : _stateSource = stateSource,
        _gate = AttachmentUploadGate(
            validator ?? AttachmentUploadValidator([const AttachmentSizeLimitRule()])),
        _feedbackBuilder = feedbackBuilder ?? AttachmentValidationFeedbackImpl.new;

  /// Validates the picked [files] then runs [onAllowed] when the upload may proceed.
  Future<void> validateFiles({
    BuildContext? context,
    required List<FileInfo> files,
    required VoidCallback onAllowed,
  }) {
    return _validate(
      context: context,
      request: _requestFactory.fromProposedFiles(
        files: files,
        state: _stateSource,
      ),
      onAllowed: onAllowed,
    );
  }

  /// Validates an already uploaded [attachment] being re-attached, then runs
  /// [onAllowed] when the upload may proceed.
  Future<void> validateAttachment({
    BuildContext? context,
    required Attachment attachment,
    required VoidCallback onAllowed,
  }) {
    final attachmentBytes = (attachment.size?.value ?? 0).toInt();
    final isRegularAttachment = !attachment.isDispositionInlined();

    return _validate(
      context: context,
      request: _requestFactory.fromProposedBytes(
        proposedAllAttachmentBytes: attachmentBytes,
        proposedRegularAttachmentBytes: isRegularAttachment ? attachmentBytes : 0,
        state: _stateSource,
      ),
      onAllowed: onAllowed,
    );
  }

  /// Whether what is already attached exceeds the server hard cap, without
  /// showing any dialog.
  bool isExceededMaxSizeAttachmentsPerEmail() {
    return AttachmentSizeLimitPolicy.isExceededMaxSizeAttachmentsPerEmail(
      allAttachmentBytes: _stateSource.currentAllAttachmentBytes,
      hardLimitBytes: _stateSource.hardLimitBytes,
    );
  }

  Future<void> _validate({
    BuildContext? context,
    required AttachmentUploadRequest request,
    required VoidCallback onAllowed,
  }) async {
    final allowed = await _gate.permits(
      request: request,
      feedbackFactory: () {
        final resolvedContext = context ?? currentContext;
        return resolvedContext == null ? null : _feedbackBuilder(resolvedContext);
      },
    );
    if (allowed) {
      onAllowed();
    }
  }
}
