import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/email_recovery_form_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/check_box_has_attachment_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/date_selection_field/date_selection_field_mobile_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/limits_banner.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/list_button_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/text_input_field_suggestion_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/text_input_field_widget.dart';
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
                      LimitsBanner(
                        bannerContent: AppLocalizations.of(context).recoverDeletedMessagesBannerContent(controller.getRestorationHorizonAsString()),
                      ),
                      const SizedBox(height: 16.0),
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
                      TextInputFieldWidget(
                        field: EmailRecoveryField.subject,
                        responsiveUtils: controller.responsiveUtils,
                        imagePaths: controller.imagePaths,
                        textEditingController: controller.subjectFieldInputController,
                        currentFocusNode: controller.focusManager.subjectFieldFocusNode,
                        nextFocusNode: controller.focusManager.recipientsFieldFocusNode,
                      ),
                      Obx(() => TextInputFieldSuggestionWidget(
                        keyTagEditor: controller.recipientsFieldKey,
                        field: EmailRecoveryField.recipients,
                        listEmailAddress: controller.listRecipients,
                        responsiveUtils: controller.responsiveUtils,
                        focusNode: controller.focusManager.recipientsFieldFocusNode,
                        nextFocusNode: controller.focusManager.senderFieldFocusNode,
                        expandMode: controller.recipientsExpandMode.value,
                        minInputLengthAutocomplete: controller.minInputLengthAutocomplete,
                        textEditingController: controller.recipientsFieldInputController,
                        onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                        onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                        onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                      )),
                      Obx(() => TextInputFieldSuggestionWidget(
                        keyTagEditor: controller.senderFieldKey,
                        field: EmailRecoveryField.sender,
                        listEmailAddress: controller.listSenders,
                        responsiveUtils: controller.responsiveUtils,
                        focusNode: controller.focusManager.senderFieldFocusNode,
                        nextFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
                        expandMode: controller.senderExpandMode.value,
                        minInputLengthAutocomplete: controller.minInputLengthAutocomplete,
                        textEditingController: controller.senderFieldInputController,
                        onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                        onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                        onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                      )),
                      Obx(() => CheckBoxHasAttachmentWidget(
                        hasAttachmentValue: controller.hasAttachment.value,
                        currentFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
                        onChanged: (value) => controller.onChangeHasAttachment(value),
                      ))
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EmailRecoveryFormStyles.bottomAreaPadding,
              child: ListButtonWidget(
                onCancel: () => controller.closeView(context),
                onRestore: () => controller.onRestore(context),
                responsiveUtils: controller.responsiveUtils,
              ),
            )
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