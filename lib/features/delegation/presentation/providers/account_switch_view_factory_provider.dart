import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/dashboard_account_switch_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/getx_account_switch_dashboard.dart';

typedef AccountSwitchViewFactory = AccountSwitchView Function(BuildContext context);

/// Builds the dashboard switch view for avatar menu / Viewing banner entry points.
final accountSwitchViewFactoryProvider =
    Provider<AccountSwitchViewFactory>((ref) {
  return (context) => DashboardAccountSwitchView(
        ProviderScope.containerOf(context, listen: false),
        GetXAccountSwitchDashboard(Get.find<MailboxDashBoardController>()),
        Get.key,
      );
});
