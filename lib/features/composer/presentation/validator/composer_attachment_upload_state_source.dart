
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request_factory.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_state_source.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

/// Reads the composer's current upload state for the attachment upload
/// validator.
class ComposerAttachmentUploadStateSource implements AttachmentUploadStateSource {
  /// Live reference: byte totals below are read from it on every access.
  final UploadController uploadController;

  @override
  final int warningLimitBytes;
  final num? Function() maxSizeAttachmentsPerEmailProvider;

  const ComposerAttachmentUploadStateSource({
    required this.uploadController,
    required this.warningLimitBytes,
    required this.maxSizeAttachmentsPerEmailProvider,
  });

  /// Resolves the limits from the raw server capability value.
  factory ComposerAttachmentUploadStateSource.fromServerCapability({
    required UploadController uploadController,
    required num? Function() maxSizeAttachmentsPerEmail,
  }) {
    return ComposerAttachmentUploadStateSource(
      uploadController: uploadController,
      warningLimitBytes: AppConfig.warningAttachmentFileSizeInMegabytes * 1024 * 1024,
      maxSizeAttachmentsPerEmailProvider: maxSizeAttachmentsPerEmail,
    );
  }

  @override
  int? get hardLimitBytes => AttachmentUploadRequestFactory
      .normalizeServerLimitBytes(maxSizeAttachmentsPerEmailProvider());

  @override
  int get currentAllAttachmentBytes =>
      uploadController.regularAttachmentsTotalBytes +
      uploadController.inlineAttachmentsTotalBytes;

  @override
  int get currentRegularAttachmentBytes =>
      uploadController.regularAttachmentsTotalBytes;
}
