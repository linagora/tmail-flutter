import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/email_recovery_form_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/date_selection_field/date_selection_field_mobile_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRecoveryFormMobileBuilder extends GetWidget<EmailRecoveryController> {
  @override
  final controller = Get.find<EmailRecoveryController>();
  
  EmailRecoveryFormMobileBuilder({super.key});

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
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => DateSelectionFieldMobileWidget(
                        field: EmailRecoveryField.deletionDate,
                        recoveryTimeSelected: controller.deletionDateFieldSelected.value,
                        imagePaths: controller.imagePaths,
                        onTap: () => controller.onSelectDeletionDateRange(context),
                        startDate: controller.startDeletionDate.value,
                        endDate: controller.endDeletionDate.value,
                      )),
                      Obx(() => DateSelectionFieldMobileWidget(
                        field: EmailRecoveryField.receptionDate,
                        recoveryTimeSelected: controller.receptionDateFieldSelected.value,
                        imagePaths: controller.imagePaths,
                        onTap: () => controller.onSelectReceptionDateRange(context),
                        startDate: controller.startReceptionDate.value,
                        endDate: controller.endReceptionDate.value,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: EmailRecoveryFormStyles.iconClosePositionTop,
          left: EmailRecoveryFormStyles.iconClosePositionRight,
          child: buildIconWeb(
            icon: SvgPicture.asset(
              controller.imagePaths.icClose,
              height: 24,
              width: 24,
              fit: BoxFit.fill,
            ),
            tooltip: AppLocalizations.of(context).close,
            onTap: () => controller.closeView(context),
          ),
        )
      ],
    );
  }
}