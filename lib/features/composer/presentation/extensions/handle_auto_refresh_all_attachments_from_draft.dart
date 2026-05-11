import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension HandleRefreshAllAttachmentsFromDraft on ComposerController {
  void autoRefreshAllBlobIdAttachmentsFromDraft({
    required Id oldBlobId,
    required Id newBlobId,
  }) {
    uploadController.refreshAllBlobIdForAttachments(
      oldBlobId: oldBlobId,
      newBlobId: newBlobId,
    );
  }
}
