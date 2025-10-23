import 'package:core/data/network/download/download_manager.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_eml_content_in_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_preview_eml_content_from_persistent_to_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/download_interactor_bindings.dart';

class EmailPreviewerBindings extends Bindings {
  @override
  void dependencies() {
    DownloadInteractorBindings().dependencies();
    Get.lazyPut(
      () => EmailPreviewerController(
        Get.find<GetPreviewEmailEMLContentSharedInteractor>(),
        Get.find<MovePreviewEmlContentFromPersistentToMemoryInteractor>(),
        Get.find<RemovePreviewEmailEmlContentSharedInteractor>(),
        Get.find<GetPreviewEmlContentInMemoryInteractor>(),
        Get.find<ParseEmailByBlobIdInteractor>(),
        Get.find<PreviewEmailFromEmlFileInteractor>(),
        Get.find<DownloadAttachmentForWebInteractor>(),
        Get.find<DownloadManager>(),
      ),
    );
  }
}
