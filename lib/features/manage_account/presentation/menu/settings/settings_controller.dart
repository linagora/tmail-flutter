import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

class SettingsController extends GetxController with ContactSupportMixin {
  final manageAccountDashboardController = Get.find<ManageAccountDashBoardController>();
  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  void selectSettings(AccountMenuItem accountMenuItem) => manageAccountDashboardController.selectSettings(accountMenuItem);

  void backToUniversalSettings() => manageAccountDashboardController.backToUniversalSettings();
}