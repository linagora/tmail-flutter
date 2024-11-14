import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/email_recovery_form_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/check_box_has_attachment_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/date_selection_field/date_selection_field_web_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/limits_banner.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/list_button_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/text_input_field_suggestion_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/text_input_field_widget.dart';
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
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EmailRecoveryFormStyles.inputAreaPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LimitsBanner(
                        bannerContent: AppLocalizations.of(context).recoverDeletedMessagesBannerContent(controller.getRestorationHorizonAsString()),
                      ),
                      const SizedBox(height: 16.0),
                      Obx(() => DateSelectionFieldWebWidget(
                        field: EmailRecoveryField.deletionDate,
                        imagePaths: controller.imagePaths,
                        responsiveUtils: controller.responsiveUtils,
                        startDate: controller.startDeletionDate.value,
                        endDate: controller.endDeletionDate.value,
                        recoveryTimeSelected: controller.deletionDateFieldSelected.value,
                        onTapCalendar: () => controller.onSelectDeletionDateRange(context),
                        onRecoveryTimeSelected: (type) => controller.onDeletionDateTypeSelected(context, type),
                        restorationHorizon: controller.getRestorationHorizonAsDateTime(),
                      )),
                      Obx(() => DateSelectionFieldWebWidget(
                        field: EmailRecoveryField.receptionDate,
                        imagePaths: controller.imagePaths,
                        responsiveUtils: controller.responsiveUtils,
                        startDate: controller.startReceptionDate.value,
                        endDate: controller.endReceptionDate.value,
                        recoveryTimeSelected: controller.receptionDateFieldSelected.value,
                        onTapCalendar: () => controller.onSelectReceptionDateRange(context),
                        onRecoveryTimeSelected: (type) => controller.onReceptionDateTypeSelected(context, type),
                        restorationHorizon: controller.getRestorationHorizonAsDateTime(),
                      )),
                        TextInputFieldWidget(
                          field: EmailRecoveryField.subject,
                          textEditingController: controller.subjectFieldInputController,
                          currentFocusNode: controller.focusManager.subjectFieldFocusNode,
                          nextFocusNode: controller.focusManager.recipientsFieldFocusNode,
                          responsiveUtils: controller.responsiveUtils,
                          imagePaths: controller.imagePaths,
                        ),
                        Obx(() => TextInputFieldSuggestionWidget(
                          keyTagEditor: controller.recipientsFieldKey,
                          field: EmailRecoveryField.recipients,
                          listEmailAddress: controller.listRecipients,
                          responsiveUtils: controller.responsiveUtils,
                          expandMode: controller.recipientsExpandMode.value,
                          minInputLengthAutocomplete: controller.minInputLengthAutocomplete,
                          textEditingController: controller.recipientsFieldInputController,
                          focusNode: controller.focusManager.recipientsFieldFocusNode,
                          nextFocusNode: controller.listSenders.length != 1
                            ? controller.focusManager.senderFieldFocusNode
                            : controller.focusManager.attachmentCheckboxFocusNode,
                          onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                          onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                          onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                        )),
                        Obx(() => TextInputFieldSuggestionWidget(
                          keyTagEditor: controller.senderFieldKey,
                          field: EmailRecoveryField.sender,
                          listEmailAddress: controller.listSenders,
                          responsiveUtils: controller.responsiveUtils,
                          expandMode: controller.senderExpandMode.value,
                          minInputLengthAutocomplete: controller.minInputLengthAutocomplete,
                          textEditingController: controller.senderFieldInputController,
                          focusNode: controller.focusManager.senderFieldFocusNode,
                          nextFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
                          onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                          onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                          onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                        )),
                    ],
                  ),
                ),
              )
            ),
            Padding(
              padding: EmailRecoveryFormStyles.bottomAreaPadding,
              child: Row(
                children: [
                  Obx(() => CheckBoxHasAttachmentWidget(
                    hasAttachmentValue: controller.hasAttachment.value,
                    currentFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
                    onChanged: (value) => controller.onChangeHasAttachment(value),
                  )),
                  SizedBox(width: controller.responsiveUtils.getDeviceWidth(context) * 0.04),
                  Expanded(
                    child: ListButtonWidget(
                      onCancel: () => controller.closeView(context),
                      onRestore: () => controller.onRestore(context),
                      responsiveUtils: controller.responsiveUtils,
                    ),
                  )
                ],
              ),
            )
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