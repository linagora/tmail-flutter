import 'dart:math';

import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/checkbox/custom_icon_labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_autocomplete_input_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_date_drop_down_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_with_tab_key_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_label_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/pop_back_barrier_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/extension/handle_drag_email_tag_between_field_extension.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/limits_banner.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/list_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRecoveryFormDesktopBuilder extends StatelessWidget {

  final EmailRecoveryController controller;

  const EmailRecoveryFormDesktopBuilder(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final child = PopBackBarrierWidget(
      child: Center(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Colors.white,
              ),
              width: min(
                controller.responsiveUtils.getSizeScreenWidth(context),
                576,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  FocusTraversalGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 16,
                              vertical: 24
                            ),
                            child: Text(
                              appLocalizations.recoverDeletedMessages,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ThemeUtils.textStyleM3HeadlineSmall,
                            ),
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LimitsBanner(
                                  bannerContent: appLocalizations
                                      .dialogRecoverDeletedMessagesDescription(
                                    controller.getRestorationHorizonAsString(),
                                  ),
                                  padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 32,
                                  ),
                                  isCenter: true,
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Row(
                                    children: [
                                      DefaultLabelFieldWidget(
                                        label: FilterField.deletionDate.getTitle(appLocalizations),
                                        width: 112,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Obx(() => DefaultDateDropDownFieldWidget(
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
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Row(
                                    children: [
                                      DefaultLabelFieldWidget(
                                        label: FilterField.receptionDate.getTitle(appLocalizations),
                                        width: 112,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Obx(() => DefaultDateDropDownFieldWidget(
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
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Row(
                                    children: [
                                      DefaultLabelFieldWidget(
                                        label: FilterField.subject.getTitle(appLocalizations),
                                        width: 112,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DefaultInputFieldWithTabKeyWidget(
                                          textEditingController: controller.subjectFieldInputController,
                                          currentFocusNode: controller.focusManager.subjectFieldFocusNode,
                                          nextFocusNode: controller.focusManager.recipientsFieldFocusNode,
                                          hintText: FilterField.recoverSubject.getHintText(appLocalizations),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Row(
                                    children: [
                                      DefaultLabelFieldWidget(
                                        label: FilterField.recipients.getTitle(appLocalizations),
                                        width: 112,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Obx(() => DefaultAutocompleteInputFieldWidget(
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
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Row(
                                    children: [
                                      DefaultLabelFieldWidget(
                                        label: FilterField.sender.getTitle(appLocalizations),
                                        width: 112,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Obx(() => DefaultAutocompleteInputFieldWidget(
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
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Obx(() => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: CustomIconLabeledCheckbox(
                                    label: AppLocalizations.of(context).hasAttachment,
                                    svgIconPath: controller.imagePaths.icCheckboxUnselected,
                                    selectedSvgIconPath: controller.imagePaths.icCheckboxSelected,
                                    focusNode: controller.focusManager.attachmentCheckboxFocusNode,
                                    value: controller.hasAttachment.value,
                                    onChanged: controller.onChangeHasAttachment,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                        ListButtonWidget(
                          onCancel: () => controller.closeView(context),
                          onRestore: () => controller.onRestore(context),
                          nextFocusNode: controller.focusManager.subjectFieldFocusNode,
                          isMobile: false,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 37,
                            vertical: 24,
                          ),
                        )
                      ],
                    ),
                  ),
                  DefaultCloseButtonWidget(
                    iconClose: controller.imagePaths.icCloseDialog,
                    onTapActionCallback: () => controller.closeView(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.20),
      body: child,
    );
  }
}