import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_autocomplete_input_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_button_arrow_down_field_with_tab_key_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_date_drop_down_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_with_tab_key_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/advanced_search/update_label_in_advanced_search_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/check_label_available_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_field_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form_bottom_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/label_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/sort_by_drop_down_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController> {
  const AdvancedSearchInputForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return FocusTraversalGroup(
      child: Column(
        children: [
          AdvancedSearchFieldWidget(
            filterField: FilterField.from,
            useHeight: false,
            child: Obx(() => DefaultAutocompleteInputFieldWidget(
              field: FilterField.from,
              listEmailAddress: controller.listFromEmailAddress,
              expandMode: controller.fromAddressExpandMode.value,
              minInputLengthAutocomplete: controller
                .mailboxDashBoardController
                .minInputLengthAutocomplete,
              controller: controller.fromEmailAddressController,
              focusNode: controller.focusManager.fromFieldFocusNode,
              nextFocusNode: controller.focusManager.toFieldFocusNode,
              keyTagEditor: controller.keyFromEmailTagEditor,
              onShowFullListEmailAddressAction: controller.showFullEmailAddress,
              onUpdateListEmailAddressAction: controller.updateListEmailAddress,
              onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
              onSearchAction: controller.onSearchAction,
              onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
            )),
          ),
          const SizedBox(height: 12),
          AdvancedSearchFieldWidget(
            filterField: FilterField.to,
            useHeight: false,
            child: Obx(() => DefaultAutocompleteInputFieldWidget(
              field: FilterField.to,
              listEmailAddress: controller.listToEmailAddress,
              expandMode: controller.toAddressExpandMode.value,
              minInputLengthAutocomplete: controller
                  .mailboxDashBoardController
                  .minInputLengthAutocomplete,
              controller: controller.toEmailAddressController,
              focusNode: controller.focusManager.toFieldFocusNode,
              nextFocusNode: controller.focusManager.subjectFieldFocusNode,
              keyTagEditor: controller.keyToEmailTagEditor,
              onShowFullListEmailAddressAction: controller.showFullEmailAddress,
              onUpdateListEmailAddressAction: controller.updateListEmailAddress,
              onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
              onSearchAction: controller.onSearchAction,
              onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
            )),
          ),
          const SizedBox(height: 12),
          AdvancedSearchFieldWidget(
            filterField: FilterField.subject,
            child: DefaultInputFieldWithTabKeyWidget(
              textEditingController: controller.subjectFilterInputController,
              currentFocusNode: controller.focusManager.subjectFieldFocusNode,
              nextFocusNode: controller.focusManager.hasKeywordFieldFocusNode,
              hintText: FilterField.subject.getHintText(appLocalizations),
              onTextChange: (value) => controller.onTextChanged(
                FilterField.subject,
                value,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdvancedSearchFieldWidget(
            filterField: FilterField.hasKeyword,
            child: DefaultInputFieldWithTabKeyWidget(
              textEditingController: controller.hasKeyWordFilterInputController,
              currentFocusNode: controller.focusManager.hasKeywordFieldFocusNode,
              nextFocusNode: controller.focusManager.notKeywordFieldFocusNode,
              hintText: FilterField.hasKeyword.getHintText(appLocalizations),
              onTextChange: (value) => controller.onTextChanged(
                FilterField.hasKeyword,
                value,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdvancedSearchFieldWidget(
            filterField: FilterField.notKeyword,
            child: DefaultInputFieldWithTabKeyWidget(
              textEditingController: controller.notKeyWordFilterInputController,
              currentFocusNode: controller.focusManager.notKeywordFieldFocusNode,
              nextFocusNode: controller.focusManager.mailboxFieldFocusNode,
              hintText: FilterField.notKeyword.getHintText(appLocalizations),
              onTextChange: (value) => controller.onTextChanged(
                FilterField.notKeyword,
                value,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdvancedSearchFieldWidget(
            filterField: FilterField.mailBox,
            child: Obx(() => DefaultButtonArrowDownFieldWithTabKeyWidget(
              text: controller.selectedFolderName.value ??
                  AppLocalizations.of(context).allFolders,
              iconArrowDown: controller.imagePaths.icDropDown,
              currentFocusNode: controller.focusManager.mailboxFieldFocusNode,
              nextFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
              onTap: () => controller.selectedMailBox(context),
            )),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final isLabelAvailable =
                controller.mailboxDashBoardController.isLabelAvailable;

            final labels =
                controller.mailboxDashBoardController.labelController.labels;

            final labelSelected = controller.selectedLabel.value;

            if (isLabelAvailable) {
              return AdvancedSearchFieldWidget(
                filterField: FilterField.labels,
                padding: const EdgeInsets.only(bottom: 12),
                child: LabelDropDownButton(
                  imagePaths: controller.imagePaths,
                  labels: labels,
                  labelSelected: labelSelected,
                  onSelectLabelsActions: controller.setSelectedLabel,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          AdvancedSearchFieldWidget(
            filterField: FilterField.date,
            child: Obx(() => DefaultDateDropDownFieldWidget(
              imagePaths: controller.imagePaths,
              receiveTimeTypes: EmailReceiveTimeType.valuesForSearch,
              startDate: controller.startDate.value,
              endDate: controller.endDate.value,
              receiveTimeTypeSelected: controller.receiveTimeType.value,
              onReceiveTimeSelected: (receiveTime) =>
                  controller.updateReceiveDateSearchFilter(
                    context,
                    receiveTime,
                  ),
              onOpenDatPicker: () => controller.selectDateRange(context),
            )),
          ),
          const SizedBox(height: 12),
          AdvancedSearchFieldWidget(
            filterField: FilterField.sortBy,
            child: Obx(() => SortByDropDownButton(
              imagePaths: controller.imagePaths,
              sortOrderSelected: controller.sortOrderType.value,
              onSortOrderSelected: controller.updateSortOrder,
            )),
          ),
          const SizedBox(height: 24),
          AdvancedSearchFilterFormBottomView(focusManager: controller.focusManager)
        ],
      ),
    );
  }
}
