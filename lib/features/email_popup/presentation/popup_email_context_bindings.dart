import 'package:core/data/network/download/download_manager.dart';
import 'package:core/utils/print_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_and_get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/get_html_content_from_upload_file_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/download/presentation/bindings/download_interactor_bindings.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/email/domain/context/email_context_provider.dart';
import 'package:tmail_ui_user/features/email/domain/context/popup_email_context_provider.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/unsubscribe_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_interactor_bindings.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';

/// Lightweight bindings for email popup mode.
/// Initializes only the essential dependencies needed to display emails
/// in a popup window without the full dashboard overhead.
class PopupEmailContextBindings extends BaseBindings {
  @override
  void bindingsController() {
    // Initialize download controller first
    Get.put(DownloadController(
      Get.find<DownloadManager>(),
      Get.find<PrintUtils>(),
      Get.find<DownloadAttachmentForWebInteractor>(),
      Get.find<DownloadAllAttachmentsForWebInteractor>(),
      Get.find<ParseEmailByBlobIdInteractor>(),
      Get.find<PreviewEmailFromEmlFileInteractor>(),
      Get.find<DownloadAndGetHtmlContentFromAttachmentInteractor>(),
      Get.find<GetHtmlContentFromUploadFileInteractor>(),
      Get.find<ExportAttachmentInteractor>(),
      Get.find<ExportAllAttachmentsInteractor>(),
    ));

    // Initialize the popup email context provider
    final popupProvider = PopupEmailContextProvider(
      Get.find<GetAllMailboxInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<MoveToMailboxInteractor>(),
      Get.find<MoveMultipleEmailToMailboxInteractor>(),
      Get.find<DeleteEmailPermanentlyInteractor>(),
      Get.find<UnsubscribeEmailInteractor>(),
      Get.find<DownloadController>(),
    );

    Get.put(popupProvider);
    Get.put<EmailContextProvider>(popupProvider);
  }

  @override
  void bindingsDataSource() {
    // Use EmailInteractorBindings for email-related data sources
    EmailInteractorBindings().bindingsDataSource();
    // Use IdentityInteractorsBindings for identity-related data sources
    IdentityInteractorsBindings().bindingsDataSource();
  }

  @override
  void bindingsDataSourceImpl() {
    // Use EmailInteractorBindings for email-related data source implementations
    EmailInteractorBindings().bindingsDataSourceImpl();
    // Use IdentityInteractorsBindings for identity-related data source implementations
    IdentityInteractorsBindings().bindingsDataSourceImpl();
  }

  @override
  void bindingsRepository() {
    // Use EmailInteractorBindings for email-related repositories
    EmailInteractorBindings().bindingsRepository();
    // Use IdentityInteractorsBindings for identity-related repositories
    IdentityInteractorsBindings().bindingsRepository();
  }

  @override
  void bindingsRepositoryImpl() {
    // Use EmailInteractorBindings for email-related repository implementations
    EmailInteractorBindings().bindingsRepositoryImpl();
    // Use IdentityInteractorsBindings for identity-related repository implementations
    IdentityInteractorsBindings().bindingsRepositoryImpl();
  }

  @override
  void bindingsInteractor() {
    // Initialize download interactors
    DownloadInteractorBindings().dependencies();

    // Mailbox interactors
    Get.lazyPut(() => GetAllMailboxInteractor(Get.find<MailboxRepository>()));

    // Identity interactors (need IdentityUtils)
    Get.lazyPut(() => IdentityUtils());
    Get.lazyPut(() => GetAllIdentitiesInteractor(
      Get.find<IdentityRepository>(),
      Get.find<IdentityUtils>(),
    ));

    // Email interactors
    Get.lazyPut(() => MoveToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MoveMultipleEmailToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => DeleteEmailPermanentlyInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => UnsubscribeEmailInteractor(Get.find<EmailRepository>()));
  }
}
