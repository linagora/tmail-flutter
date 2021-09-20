import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/email/presentation/email_bindings.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_bindings.dart';

class MailboxDashBoardBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());
    Get.lazyPut(() => GetUserProfileInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => AppToast());

    Get.put(MailboxDashBoardController(
      Get.find<GetUserProfileInteractor>(),
      Get.find<AppToast>()));

    MailboxBindings().dependencies();
    ThreadBindings().dependencies();
    EmailBindings().dependencies();
  }
}