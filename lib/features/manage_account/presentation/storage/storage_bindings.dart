import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_interactor_bindings.dart';

class StorageBindings extends Bindings {
  @override
  void dependencies() {
    QuotasInteractorBindings().dependencies();
    Get.lazyPut(() => StorageController(Get.find<GetQuotasInteractor>()));
  }
}
