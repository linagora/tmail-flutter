import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/paywall/presentation/saas_premium_mixin.dart';

class StorageController extends BaseController with SaaSPremiumMixin {
  final dashBoardController = Get.find<ManageAccountDashBoardController>();

  bool validatePremiumIsAvailable() {
    final accountId = dashBoardController.accountId.value;
    final session = dashBoardController.sessionCurrent;

    if (accountId == null || session == null) {
      return false;
    }
    return isPremiumAvailable(accountId: accountId, session: session);
  }

  void onUpgradeStorage(BuildContext context) {
    dashBoardController.paywallController?.navigateToPaywall(context);
  }
}
