import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_capabilities_provider.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';

/// The vacation banner of the shown mailbox, with no link to the vacation settings while Settings cannot open.
class DashboardVacationBanner extends ConsumerWidget {
  final _dashboardController = Get.find<MailboxDashBoardController>();
  final VacationResponse vacationResponse;
  final EdgeInsetsGeometry margin;

  DashboardVacationBanner({super.key, required this.vacationResponse, required this.margin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canOpenSettings = ref.watch(shownAccountCapabilitiesProvider).canOpenSettings;
    return VacationNotificationMessageWidget(
      margin: margin,
      vacationResponse: vacationResponse,
      actionGotoVacationSetting: canOpenSettings ? _dashboardController.goToVacationSetting : null,
      actionEndNow: _dashboardController.disableVacationResponder,
    );
  }
}
