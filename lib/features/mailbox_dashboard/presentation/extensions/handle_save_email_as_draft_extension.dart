
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleSaveEmailAsDraftExtension on MailboxDashBoardController {

  void handleUpdateEmailAsDraftsSuccess() {
    if (currentContext == null || currentOverlayContext == null) return;

    appToast.showToastMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentContext!).drafts_saved,
      leadingSVGIcon: imagePaths.icMailboxDrafts,
      leadingSVGIconColor: Colors.white,
      backgroundColor: AppColor.toastSuccessBackgroundColor,
      textColor: Colors.white,
    );
  }
}