
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/dashboard/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_property.dart';

class ManageAccountMenuController extends BaseController {

  final dashBoardController = Get.find<ManageAccountDashBoardController>();

  final listAccountProperties = <AccountProperty>[
    AccountProperty.profiles
  ];

  @override
  void onDone() {
  }

  @override
  void onError(error) {
  }
}