
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';

class DeepLinkBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(AutoSignInViaDeepLinkInteractor(
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<AccountRepository>(),
      Get.find<CredentialRepository>(),
    ));
    Get.put(DeepLinksManager(Get.find<AutoSignInViaDeepLinkInteractor>()));
  }
}