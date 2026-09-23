import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';

/// An alternative to the failure dialog, e.g. upload oversize to Drive instead.
///
/// Called only for rejections with files. False (not handled) shows the dialog.
/// True means it took over and owns all feedback; completes at takeover, not
/// at upload end. A throw declines only before any UI, after that own errors.
abstract interface class AttachmentUploadRecovery {
  Future<bool> recover(AttachmentUploadFailure failure, AttachmentUploadRequest request);
}

/// Only assigns fields; lookups go in `recover`, inside the gate's try.
typedef AttachmentUploadRecoveryBuilder =
    AttachmentUploadRecovery Function(BuildContext context);
