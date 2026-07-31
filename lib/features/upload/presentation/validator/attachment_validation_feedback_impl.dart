
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/attachment_confirmation_presenter.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/attachment_validation_failure_presenter.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback.dart';

final class AttachmentValidationFeedbackImpl implements AttachmentValidationFeedback {
  final BuildContext _context;

  const AttachmentValidationFeedbackImpl(this._context);

  @override
  Future<void> showFailure(AttachmentUploadFailure failure) async {
    if (!_context.mounted) return;
    await AttachmentValidationFailurePresenter.present(_context, failure);
  }

  @override
  Future<bool> confirmAll(List<AttachmentUploadPrompt> prompts) async {
    for (final prompt in prompts) {
      if (!_context.mounted) return false;
      if (!await AttachmentConfirmationPresenter.ask(_context, prompt)) return false;
    }
    return true;
  }
}
