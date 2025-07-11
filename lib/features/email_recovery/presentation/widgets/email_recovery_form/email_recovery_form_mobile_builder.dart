import 'package:core/presentation/views/checkbox/custom_icon_labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_app_bar_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_autocomplete_input_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_date_drop_down_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_with_tab_key_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_label_field_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/extension/handle_drag_email_tag_between_field_extension.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/limits_banner.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/list_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRecoveryFormMobileBuilder extends StatelessWidget {

  final EmailRecoveryController controller;

  const EmailRecoveryFormMobileBuilder(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: ColoredBox(
            color: Colors.white,
            child: FocusTraversalGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultAppBarWidget(
                    title: appLocalizations.recoverDeletedMessages,
                    imagePaths: controller.imagePaths,
                    responsiveUtils: controller.responsiveUtils,
                    onBackAction: () => controller.closeView(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LimitsBanner(
                            bannerContent: appLocalizations
                              .dialogRecoverDeletedMessagesDescription(
                                controller.getRestorationHorizonAsString(),
                              ),
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 32,
                              vertical: 4,
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          DefaultLabelFieldWidget(
                            label: FilterField.deletionDate.getTitle(appLocalizations),
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          ),
                          Obx(() => DefaultDateDropDownFieldWidget(
                            imagePaths: controller.imagePaths,
                            startDate: controller.startDeletionDate.value,
                            endDate: controller.endDeletionDate.value,
                            onReceiveTimeSelected: (receiveTimeType) {
                                  controller.onDeletionDateTypeSelected(
                                    context,
                                    receiveTimeType,
                                  );
                                },
                            onOpenDatPicker: () =>
                                controller.onSelectDeletionDateRange(context),
                            receiveTimeTypes: controller.deletionDateTimeTypes,
                            receiveTimeTypeSelected:
                              controller.deletionDateFieldSelected.value,
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          )),
                          const SizedBox(height: 15.0),
                          DefaultLabelFieldWidget(
                            label: FilterField.receptionDate.getTitle(appLocalizations),
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          ),
                          Obx(() => DefaultDateDropDownFieldWidget(
                            imagePaths: controller.imagePaths,
                            startDate: controller.startReceptionDate.value,
                            endDate: controller.endReceptionDate.value,
                            onReceiveTimeSelected: (receiveTimeType) {
                              controller.onReceptionDateTypeSelected(
                                    context,
                                    receiveTimeType,
                                  );
                                },
                            onOpenDatPicker: () =>
                              controller.onSelectReceptionDateRange(context),
                            receiveTimeTypes: controller.receptionDateTimeTypes,
                            receiveTimeTypeSelected:
                              controller.receptionDateFieldSelected.value,
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          )),
                          const SizedBox(height: 15.0),
                          DefaultLabelFieldWidget(
                            label: FilterField.subject.getTitle(appLocalizations),
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          ),
                          DefaultInputFieldWithTabKeyWidget(
                            textEditingController: controller.subjectFieldInputController,
                            currentFocusNode: controller.focusManager.subjectFieldFocusNode,
                            nextFocusNode: controller.focusManager.recipientsFieldFocusNode,
                            hintText: FilterField.recoverSubject.getHintText(appLocalizations),
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          ),
                          const SizedBox(height: 15.0),
                          DefaultLabelFieldWidget(
                            label: FilterField.recipients.getTitle(appLocalizations),
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          ),
                          Obx(() => DefaultAutocompleteInputFieldWidget(
                            field: FilterField.recipients,
                            listEmailAddress: controller.listRecipients,
                            expandMode: controller.recipientsExpandMode.value,
                            minInputLengthAutocomplete: controller.minInputLengthAutocomplete,
                            controller: controller.recipientsFieldInputController,
                            focusNode: controller.focusManager.recipientsFieldFocusNode,
                            nextFocusNode: controller.focusManager.senderFieldFocusNode,
                            keyTagEditor: controller.recipientsFieldKey,
                            onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                            onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                            onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                            onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          )),
                          const SizedBox(height: 15.0),
                          DefaultLabelFieldWidget(
                            label: FilterField.sender.getTitle(appLocalizations),
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          ),
                          Obx(() => DefaultAutocompleteInputFieldWidget(
                            field: FilterField.sender,
                            listEmailAddress: controller.listSenders,
                            expandMode: controller.senderExpandMode.value,
                            minInputLengthAutocomplete: controller.minInputLengthAutocomplete,
                            controller: controller.senderFieldInputController,
                            focusNode: controller.focusManager.senderFieldFocusNode,
                            nextFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
                            keyTagEditor: controller.senderFieldKey,
                            onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                            onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                            onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                            onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                          )),
                          const SizedBox(height: 15.0),
                          Obx(() => CustomIconLabeledCheckbox(
                            label: AppLocalizations.of(context).hasAttachment,
                            svgIconPath: controller.imagePaths.icCheckboxUnselected,
                            selectedSvgIconPath: controller.imagePaths.icCheckboxSelected,
                            focusNode: controller.focusManager.attachmentCheckboxFocusNode,
                            value: controller.hasAttachment.value,
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                            onChanged: controller.onChangeHasAttachment,
                          )),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                  ListButtonWidget(
                    onCancel: () => controller.closeView(context),
                    onRestore: () => controller.onRestore(context),
                    nextFocusNode: controller.focusManager.subjectFieldFocusNode,
                    isMobile: true,
                    padding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 16,
                      top: 12,
                      bottom: 44,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}