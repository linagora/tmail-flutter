import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';

/// An alternative to the failure dialog, e.g. upload oversize to Drive instead.
///
/// `true` means this recovery took over: dialog skipped, recovery owns
/// feedback from here on. Completes at takeover, not upload completion —
/// awaiting the transfer here would hold every `validateFiles` caller.
///
/// A throw counts as declining: the gate falls back to the dialog.
abstract interface class AttachmentUploadRecovery {
  Future<bool> recover(AttachmentUploadFailure failure, AttachmentUploadRequest request);
}

typedef AttachmentUploadRecoveryBuilder =
    AttachmentUploadRecovery Function(BuildContext context);
