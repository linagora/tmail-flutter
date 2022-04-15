import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/email_bindings.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_bindings.dart';

class MailboxDashBoardBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    MailboxBindings().dependencies();
    ThreadBindings().dependencies();
    EmailBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.put(MailboxDashBoardController(
      Get.find<MoveToMailboxInteractor>(),
      Get.find<DeleteEmailPermanentlyInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => EmailDataSourceImpl(Get.find<EmailAPI>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<DioClient>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetUserProfileInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => RemoveEmailDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MoveToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => DeleteEmailPermanentlyInteractor(Get.find<EmailRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => EmailRepositoryImpl(
        Get.find<EmailDataSource>(),
        Get.find<HtmlDataSource>()
    ));
  }
}