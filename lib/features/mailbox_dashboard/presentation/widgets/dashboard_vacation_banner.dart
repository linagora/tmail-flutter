import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_capabilities_provider.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';

/// My vacation banner, hidden while a delegated mailbox is shown.
class DashboardVacationBanner extends ConsumerWidget {
  final _dashboardController = Get.find<MailboxDashBoardController>();
  final VacationResponse vacationResponse;
  final EdgeInsetsGeometry margin;

  DashboardVacationBanner({super.key, required this.vacationResponse, required this.margin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(shownAccountCapabilitiesProvider);
    if (!capabilities.showsMyVacationBanner) return const SizedBox.shrink();
    final canOpenSettings = capabilities.canOpenSettings;
    return VacationNotificationMessageWidget(
      margin: margin,
      vacationResponse: vacationResponse,
      actionGotoVacationSetting: canOpenSettings ? _dashboardController.goToVacationSetting : null,
      actionEndNow: _dashboardController.disableVacationResponder,
    );
  }
}
