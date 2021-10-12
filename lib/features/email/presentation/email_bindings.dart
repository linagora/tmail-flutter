import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class EmailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmailDataSourceImpl(Get.find<EmailAPI>()));
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut(() => HtmlDataSourceImpl(Get.find<HtmlAnalyzer>()));
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut(() => EmailRepositoryImpl(
      Get.find<EmailDataSource>(),
      Get.find<HtmlDataSource>()));
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.put(SendEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsEmailReadInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());
    Get.lazyPut(() => DownloadAttachmentsInteractor(
      Get.find<EmailRepository>(),
      Get.find<CredentialRepository>()));
    Get.lazyPut(() => ExportAttachmentInteractor(
      Get.find<EmailRepository>(),
      Get.find<CredentialRepository>()));
    Get.lazyPut(() => MoveToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsStarEmailInteractor(Get.find<EmailRepository>()));
    Get.put(EmailController(
      Get.find<GetEmailContentInteractor>(),
      Get.find<MarkAsEmailReadInteractor>(),
      Get.find<DownloadAttachmentsInteractor>(),
      Get.find<DeviceManager>(),
      Get.find<AppToast>(),
      Get.find<ExportAttachmentInteractor>(),
      Get.find<MoveToMailboxInteractor>(),
      Get.find<MarkAsStarEmailInteractor>()));
  }
}