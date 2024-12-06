import 'package:get/get.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/save_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/transform_list_signature_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_interactors_bindings.dart';

class IdentityBindings extends Bindings {

  @override
  void dependencies() {
    IdentityInteractorsBindings().dependencies();

    Get.put(IdentitiesController(
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<DeleteIdentityInteractor>(),
      Get.find<CreateNewIdentityInteractor>(),
      Get.find<EditIdentityInteractor>(),
      Get.find<CreateNewDefaultIdentityInteractor>(),
      Get.find<EditDefaultIdentityInteractor>(),
      Get.find<TransformListSignatureInteractor>(),
      Get.find<SaveIdentityCacheOnWebInteractor>(),
    ));
  }
}