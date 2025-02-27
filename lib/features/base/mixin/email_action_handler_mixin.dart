
import 'dart:ui';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin EmailActionHandlerMixin implements MessageDialogActionMixin {
  Future<void> showConfirmDialogWhenMakeToActionForSelectionAllEmails({
    required ImagePaths imagePaths,
    required int totalEmails,
    required String folderName,
    required VoidCallback onConfirmAction,
  }) async {
    if (currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);

    await showConfirmDialogAction(
      currentContext!,
      appLocalizations.messageConfirmationDialogWhenMakeToActionForSelectionAllEmailsInMailbox(
        totalEmails,
        folderName,
      ),
      appLocalizations.ok,
      title: appLocalizations.confirmBulkAction,
      icon: SvgPicture.asset(
        imagePaths.icQuotasWarning,
        colorFilter: AppColor.colorBackgroundQuotasWarning.asFilter(),
      ),
      onConfirmAction: onConfirmAction,
    );
  }
}