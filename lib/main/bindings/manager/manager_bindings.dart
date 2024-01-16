
import 'package:core/presentation/resources/image_paths.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/main/utils/authenticated_account_manager.dart';

class ManagerBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(AuthenticatedAccountManager(
      Get.find<GetAllAuthenticatedAccountInteractor>(),
      Get.find<ImagePaths>(),
    ));
  }
}