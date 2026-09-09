import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_controller.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';

class StorageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StorageController(
      dashBoardController: Get.find<ManageAccountDashBoardController>(),
      getPaywallUrlInteractor: Get.find<GetPaywallUrlInteractor>(),
    ));
  }
}
