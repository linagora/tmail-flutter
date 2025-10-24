import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_and_get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_interactor_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';

class EmailBindings extends Bindings {
  final EmailId? currentEmailId;

  EmailBindings({this.currentEmailId});

  String? get tag => currentEmailId?.id.value;

  void _bindingsController() {
    Get.put(SingleEmailController(
      Get.find<GetEmailContentInteractor>(),
      Get.find<MarkAsEmailReadInteractor>(),
      Get.find<DownloadAttachmentsInteractor>(),
      Get.find<DeviceManager>(),
      Get.find<ExportAttachmentInteractor>(),
      Get.find<MarkAsStarEmailInteractor>(),
      Get.find<DownloadAttachmentForWebInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<StoreOpenedEmailInteractor>(),
      Get.find<PrintEmailInteractor>(),
      Get.find<ParseEmailByBlobIdInteractor>(),
      Get.find<PreviewEmailFromEmlFileInteractor>(),
      Get.find<DownloadAndGetHtmlContentFromAttachmentInteractor>(),
      Get.find<DownloadAllAttachmentsForWebInteractor>(),
      Get.find<ExportAllAttachmentsInteractor>(),
      currentEmailId: currentEmailId,
    ), tag: tag);
  }

  @override
  void dependencies() {
    EmailInteractorBindings().dependencies();
    _bindingsController();
  }
}