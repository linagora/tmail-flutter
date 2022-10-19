import 'package:get/get.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_interactors_bindings.dart';

class IdentityCreatorBindings extends Bindings {

  @override
  void dependencies() {
    IdentityInteractorsBindings().dependencies();
    Get.lazyPut(() => VerifyNameInteractor());

    Get.lazyPut(() => IdentityCreatorController(
      Get.find<VerifyNameInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
    ));
  }
}