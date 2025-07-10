import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_no_icon_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form_bottom_view.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/date_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/label_advanced_search_field_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/sort_by_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/text_field_autocomplete_email_address_web.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController>
    with PopupContextMenuActionMixin {
  AdvancedSearchInputForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: Column(
        children: [
          Obx(() => TextFieldAutocompleteEmailAddressWeb(
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
          const SizedBox(height: 12),
          Obx(() => TextFieldAutocompleteEmailAddressWeb(
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
          const SizedBox(height: 12),
          _buildFilterField(
            textEditingController: controller.subjectFilterInputController,
            context: context,
            filterField: FilterField.subject,
            currentFocusNode: controller.focusManager.subjectFieldFocusNode,
            nextFocusNode: controller.focusManager.hasKeywordFieldFocusNode,
            onTextChange: (value) => controller.onTextChanged(
              FilterField.subject,
              value
            ),
          ),
          const SizedBox(height: 12),
          _buildFilterField(
            textEditingController: controller.hasKeyWordFilterInputController,
            context: context,
            filterField: FilterField.hasKeyword,
            currentFocusNode: controller.focusManager.hasKeywordFieldFocusNode,
            nextFocusNode: controller.focusManager.notKeywordFieldFocusNode,
            onTextChange: (value) => controller.onTextChanged(
              FilterField.hasKeyword,
              value
            ),
          ),
          const SizedBox(height: 12),
          _buildFilterField(
            textEditingController: controller.notKeyWordFilterInputController,
            context: context,
            filterField: FilterField.notKeyword,
            currentFocusNode: controller.focusManager.notKeywordFieldFocusNode,
            nextFocusNode: controller.focusManager.mailboxFieldFocusNode,
            onTextChange: (value) => controller.onTextChanged(
              FilterField.notKeyword,
              value
            ),
          ),
          const SizedBox(height: 12),
          _buildFilterField(
            textEditingController: controller.mailBoxFilterInputController,
            context: context,
            filterField: FilterField.mailBox,
            isSelectFormList: true,
            currentFocusNode: controller.focusManager.mailboxFieldFocusNode,
            nextFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
            mouseCursor: SystemMouseCursors.click,
            onTap: () => controller.selectedMailBox(context)
          ),
          const SizedBox(height: 12),
          Row(children: [
           Expanded(child: _buildFilterField(
             context: context,
             filterField: FilterField.date,
             isSelectFormList: true,
             onTap: () {
               openContextMenuAction(
                 context,
                 _buildEmailReceiveTimeTypeActionTiles(context),
               );
             },
           )),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AdvancedSearchInputFormStyle.inputFieldBorderColor,
                  width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    AdvancedSearchInputFormStyle.inputFieldBorderRadius,
                  ),
                ),
              ),
              height: AdvancedSearchInputFormStyle.inputFieldHeight,
              width: AdvancedSearchInputFormStyle.inputFieldHeight,
              child: TMailButtonWidget.fromIcon(
                icon: controller.imagePaths.icCalendarSB,
                iconSize: 22,
                iconColor: AppColor.steelGray400,
                backgroundColor: Colors.transparent,
                tooltipMessage: AppLocalizations.of(context).selectDate,
                onTapActionCallback: () => controller.selectDateRange(context),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _buildFilterField(
            context: context,
            filterField: FilterField.sortBy
          ),
          const SizedBox(height: 24),
          AdvancedSearchFilterFormBottomView(focusManager: controller.focusManager)
        ],
      ),
    );
  }

  List<Widget> _buildEmailReceiveTimeTypeActionTiles(BuildContext context) {
    return EmailReceiveTimeType.valuesForSearch
      .map((receiveTime) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemNoIconWidget(
          receiveTime.getTitle(context),
          svgIconSelected: controller.imagePaths.icFilterSelected,
          maxWidth: 320,
          isSelected: controller.receiveTimeType.value == receiveTime,
          onCallbackAction: () => controller.updateReceiveDateSearchFilter(context, receiveTime),
        )))
      .toList();
  }

  Widget _buildFilterField({
    required BuildContext context,
    required FilterField filterField,
    TextEditingController? textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
    MouseCursor? mouseCursor,
    FocusNode? currentFocusNode,
    FocusNode? nextFocusNode,
    ValueChanged<String>? onTextChange,
  }) {
    final child = [
      SizedBox(
        width: _isVerticalArrange(context) ? null : 112,
        child: LabelAdvancedSearchFieldWidget(
          name: filterField.getTitle(AppLocalizations.of(context)),
        ),
      ),
      if (_isVerticalArrange(context))
        const SizedBox(height: 12)
      else
        const SizedBox(width: 12),
      if (controller.responsiveUtils.isMobile(context))
        _buildTextField(
          isSelectFormList: isSelectFormList,
          onTap: onTap,
          context: context,
          mouseCursor: mouseCursor,
          currentFocusNode: currentFocusNode,
          nextFocusNode: nextFocusNode,
          filterField: filterField,
          textEditingController: textEditingController,
          onTextChange: onTextChange,
        )
      else if (controller.responsiveUtils.landscapeTabletSupported(context))
        if (filterField == FilterField.date)
          Obx(() => DateDropDownButton(
            imagePaths: controller.imagePaths,
            receiveTimeTypes: EmailReceiveTimeType.valuesForSearch,
            startDate: controller.startDate.value,
            endDate: controller.endDate.value,
            receiveTimeTypeSelected: controller.receiveTimeType.value,
            onReceiveTimeSelected: (receiveTime) => controller.updateReceiveDateSearchFilter(context, receiveTime),
          ))
        else if (filterField == FilterField.sortBy)
          Obx(() => SortByDropDownButton(
            imagePaths: controller.imagePaths,
            sortOrderSelected: controller.sortOrderType.value,
            onSortOrderSelected: controller.updateSortOrder,
          ))
        else
          _buildTextField(
            isSelectFormList: isSelectFormList,
            onTap: onTap,
            context: context,
            mouseCursor: mouseCursor,
            currentFocusNode: currentFocusNode,
            nextFocusNode: nextFocusNode,
            filterField: filterField,
            textEditingController: textEditingController,
            onTextChange: onTextChange,
          )
      else
        Expanded(
          child: _buildTextFieldFilterForWeb(
            isSelectFormList: isSelectFormList,
            onTap: onTap,
            context: context,
            mouseCursor: mouseCursor,
            currentFocusNode: currentFocusNode,
            nextFocusNode: nextFocusNode,
            filterField: filterField,
            textEditingController: textEditingController,
            onTextChange: onTextChange,
          ),
        )
    ];
    return _isVerticalArrange(context)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: child,
          )
        : SizedBox(
            height: AdvancedSearchInputFormStyle.inputFieldHeight,
            child: Row(children: child),
          );
  }

  bool _isVerticalArrange(BuildContext context) =>
      controller.responsiveUtils.isMobile(context) ||
      controller.responsiveUtils.landscapeTabletSupported(context);

  Widget _buildTextFieldFilterForWeb({
    required BuildContext context,
    required FilterField filterField,
    TextEditingController? textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
    MouseCursor? mouseCursor,
    FocusNode? currentFocusNode,
    FocusNode? nextFocusNode,
    ValueChanged<String>? onTextChange,
  }) {
    switch (filterField) {
      case FilterField.date:
        return Obx(() => DateDropDownButton(
          imagePaths: controller.imagePaths,
          receiveTimeTypes: EmailReceiveTimeType.valuesForSearch,
          startDate: controller.startDate.value,
          endDate: controller.endDate.value,
          receiveTimeTypeSelected: controller.receiveTimeType.value,
          onReceiveTimeSelected: (receiveTime) => controller.updateReceiveDateSearchFilter(context, receiveTime),
        ));
      case FilterField.sortBy:
        return Obx(() => SortByDropDownButton(
          imagePaths: controller.imagePaths,
          sortOrderSelected: controller.sortOrderType.value,
          onSortOrderSelected: controller.updateSortOrder,
        ));
      default:
        return _buildTextField(
          isSelectFormList: isSelectFormList,
          onTap: onTap,
          context: context,
          mouseCursor: mouseCursor,
          currentFocusNode: currentFocusNode,
          nextFocusNode: nextFocusNode,
          filterField: filterField,
          textEditingController: textEditingController,
          onTextChange: onTextChange,
        );
    }
  }

  Widget _buildTextField({
    required BuildContext context,
    required FilterField filterField,
    TextEditingController? textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
    MouseCursor? mouseCursor,
    FocusNode? currentFocusNode,
    FocusNode? nextFocusNode,
    ValueChanged<String>? onTextChange,
  }) {
    return KeyboardListener(
      focusNode: currentFocusNode ?? FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          nextFocusNode?.requestFocus();
        }
      },
      child: TextFieldBuilder(
        controller: textEditingController,
        readOnly: isSelectFormList,
        mouseCursor: mouseCursor,
        maxLines: 1,
        textInputAction: isSelectFormList ? TextInputAction.done : TextInputAction.next,
        textStyle: AdvancedSearchInputFormStyle.inputTextStyle,
        onTap: onTap,
        onTextSubmitted: (value) {
          if (isSelectFormList) {
            onTap?.call();
          } else {
            controller.onSearchAction();
            popBack();
          }
        },
        onTextChange: onTextChange,
        decoration: InputDecoration(
          constraints: const BoxConstraints(
            maxHeight: AdvancedSearchInputFormStyle.inputFieldHeight,
          ),
          filled: true,
          fillColor: AdvancedSearchInputFormStyle.inputFieldBackgroundColor,
          contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AdvancedSearchInputFormStyle.inputFieldBorderRadius),
            ),
            borderSide: BorderSide(
              width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
              color: AdvancedSearchInputFormStyle.inputFieldBorderColor,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AdvancedSearchInputFormStyle.inputFieldBorderRadius),
            ),
            borderSide: BorderSide(
              width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
              color: AdvancedSearchInputFormStyle.inputFieldBorderColor,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AdvancedSearchInputFormStyle.inputFieldBorderRadius),
            ),
            borderSide: BorderSide(
              width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
              color: AppColor.primaryColor,
            ),
          ),
          hintText: filterField.getHintText(AppLocalizations.of(context)),
          hintStyle: ThemeUtils.textStyleBodyBody3(
            color: filterField == FilterField.mailBox
                ? Colors.black
                : AppColor.m3Tertiary,
          ),
          suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
          suffixIcon: isSelectFormList
              ? buildIconWeb(
                  icon: SvgPicture.asset(
                    controller.imagePaths.icDropDown,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
