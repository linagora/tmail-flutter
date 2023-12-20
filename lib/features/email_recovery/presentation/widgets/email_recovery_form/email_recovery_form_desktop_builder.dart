import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/email_recovery_form_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRecoveryFormDesktopBuilder extends GetWidget<EmailRecoveryController> {
  @override
  final controller = Get.find<EmailRecoveryController>();

  EmailRecoveryFormDesktopBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EmailRecoveryFormStyles.padding,
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context).recoverDeletedMessages,
                style: EmailRecoveryFormStyles.titleTextStyle,
              ),
            ),
          ],
        ),
        Positioned(
          top: EmailRecoveryFormStyles.iconClosePositionTop,
          right: EmailRecoveryFormStyles.iconClosePositionRight,
          child: buildIconWeb(
            icon: SvgPicture.asset(
              controller.imagePaths.icClose,
              fit: BoxFit.fill,
              width: 24,
              height: 24,
            ),
            tooltip: AppLocalizations.of(context).close,
            onTap: () => controller.closeView(context),
          ),
        )
      ],
    );
  }
}