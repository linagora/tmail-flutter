import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_no_icon_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form_bottom_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/date_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/sort_by_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/text_field_autocomplete_email_address_web.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController>
    with PopupContextMenuActionMixin {
  AdvancedSearchInputForm({
    Key? key,
  }) : super(key: key);

  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: Column(
        children: [
          Obx(() => TextFieldAutocompleteEmailAddressWeb(
            field: AdvancedSearchFilterField.from,
            listEmailAddress: controller.listFromEmailAddress,
            expandMode: controller.fromAddressExpandMode.value,
            controller: controller.fromEmailAddressController,
            focusNode: controller.focusManager.fromFieldFocusNode,
            nextFocusNode: controller.focusManager.toFieldFocusNode,
            keyTagEditor: controller.keyFromEmailTagEditor,
            onShowFullListEmailAddressAction: controller.showFullEmailAddress,
            onUpdateListEmailAddressAction: controller.updateListEmailAddress,
            onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
            onSearchAction: () => controller.onSearchAction.call(context),
          )),
          Obx(() => TextFieldAutocompleteEmailAddressWeb(
            field: AdvancedSearchFilterField.to,
            listEmailAddress: controller.listToEmailAddress,
            expandMode: controller.toAddressExpandMode.value,
            controller: controller.toEmailAddressController,
            focusNode: controller.focusManager.toFieldFocusNode,
            nextFocusNode: controller.focusManager.subjectFieldFocusNode,
            keyTagEditor: controller.keyToEmailTagEditor,
            onShowFullListEmailAddressAction: controller.showFullEmailAddress,
            onUpdateListEmailAddressAction: controller.updateListEmailAddress,
            onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
            onSearchAction: () => controller.onSearchAction.call(context),
          )),
          _buildFilterField(
            textEditingController: controller.subjectFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.subject,
            currentFocusNode: controller.focusManager.subjectFieldFocusNode,
            nextFocusNode: controller.focusManager.hasKeywordFieldFocusNode
          ),
          _buildFilterField(
            textEditingController: controller.hasKeyWordFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.hasKeyword,
            currentFocusNode: controller.focusManager.hasKeywordFieldFocusNode,
            nextFocusNode: controller.focusManager.notKeywordFieldFocusNode
          ),
          _buildFilterField(
            textEditingController: controller.notKeyWordFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.notKeyword,
            currentFocusNode: controller.focusManager.notKeywordFieldFocusNode,
            nextFocusNode: controller.focusManager.mailboxFieldFocusNode,
          ),
          _buildFilterField(
            textEditingController: controller.mailBoxFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.mailBox,
            isSelectFormList: true,
            currentFocusNode: controller.focusManager.mailboxFieldFocusNode,
            nextFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
            mouseCursor: SystemMouseCursors.click,
            onTap: () => controller.selectedMailBox(context)
          ),
          Row(children: [
           Expanded(child: _buildFilterField(
             context: context,
             advancedSearchFilterField: AdvancedSearchFilterField.date,
             isSelectFormList: true,
             onTap: () {
               openContextMenuAction(
                 context,
                 _buildEmailReceiveTimeTypeActionTiles(context),
               );
             },
           )),
            const SizedBox(width: 10),
            buildIconWeb(
                icon: SvgPicture.asset(
                    _imagePaths.icCalendarSB,
                    width: 24,
                    height: 24,
                    fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).selectDate,
                iconPadding: EdgeInsets.zero,
                onTap: () => controller.selectDateRange(context)),
          ]),
          _buildFilterField(
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.sortBy
          ),
          AdvancedSearchFilterFormBottomView(focusManager: controller.focusManager)
        ],
      ),
    );
  }

  List<Widget> _buildEmailReceiveTimeTypeActionTiles(BuildContext context) {
    return EmailReceiveTimeType.values
      .map((receiveTime) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemNoIconWidget(
          receiveTime.getTitle(context),
          svgIconSelected: _imagePaths.icFilterSelected,
          maxWidth: 320,
          isSelected: controller.dateFilterSelectedFormAdvancedSearch.value == receiveTime,
          onCallbackAction: () => controller.updateReceiveDateSearchFilter(context, receiveTime),
        )))
      .toList();
  }

  Widget _buildFilterField({
    required BuildContext context,
    required AdvancedSearchFilterField advancedSearchFilterField,
    TextEditingController? textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
    MouseCursor? mouseCursor,
    FocusNode? currentFocusNode,
    FocusNode? nextFocusNode,
  }) {
    final child = [
      SizedBox(
        width: _responsiveUtils.isMobile(context) || _responsiveUtils.landscapeTabletSupported(context)
            ? null : 112,
        child: Text(
          advancedSearchFilterField.getTitle(context),
          style: const TextStyle(
            fontSize: 14,
            color: AppColor.colorContentEmail,
          ),
        ),
      ),
      const Padding(padding: EdgeInsets.all(4)),
      if (_responsiveUtils.isMobile(context))
        _buildTextField(
          isSelectFormList: isSelectFormList,
          onTap: onTap,
          context: context,
          mouseCursor: mouseCursor,
          currentFocusNode: currentFocusNode,
          nextFocusNode: nextFocusNode,
          advancedSearchFilterField: advancedSearchFilterField,
          textEditingController: textEditingController,
        )
      else if (_responsiveUtils.landscapeTabletSupported(context))
        if (advancedSearchFilterField == AdvancedSearchFilterField.date)
          Obx(() => DateDropDownButton(
            _imagePaths,
            startDate: controller.startDate.value,
            endDate: controller.endDate.value,
            receiveTimeSelected: controller.dateFilterSelectedFormAdvancedSearch.value,
            onReceiveTimeSelected: (receiveTime) => controller.updateReceiveDateSearchFilter(context, receiveTime),
          ))
        else if (advancedSearchFilterField == AdvancedSearchFilterField.sortBy)
          Obx(() => SortByDropDownButton(
            imagePaths: _imagePaths,
            sortOrderSelected: controller.searchController.sortOrderFiltered.value,
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
            advancedSearchFilterField: advancedSearchFilterField,
            textEditingController: textEditingController,
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
            advancedSearchFilterField: advancedSearchFilterField,
            textEditingController: textEditingController,
          ),
        )
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _responsiveUtils.isMobile(context) || _responsiveUtils.landscapeTabletSupported(context)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: child,
            )
          : SizedBox(height: 44, child: Row(children: child)),
    );
  }

  Widget _buildTextFieldFilterForWeb({
    required BuildContext context,
    required AdvancedSearchFilterField advancedSearchFilterField,
    TextEditingController? textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
    MouseCursor? mouseCursor,
    FocusNode? currentFocusNode,
    FocusNode? nextFocusNode,
  }) {
    switch (advancedSearchFilterField) {
      case AdvancedSearchFilterField.date:
        return Obx(() => DateDropDownButton(
          _imagePaths,
          startDate: controller.startDate.value,
          endDate: controller.endDate.value,
          receiveTimeSelected: controller.dateFilterSelectedFormAdvancedSearch.value,
          onReceiveTimeSelected: (receiveTime) => controller.updateReceiveDateSearchFilter(context, receiveTime),
        ));
      case AdvancedSearchFilterField.sortBy:
        return Obx(() => SortByDropDownButton(
          imagePaths: _imagePaths,
          sortOrderSelected: controller.searchController.sortOrderFiltered.value,
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
          advancedSearchFilterField: advancedSearchFilterField,
          textEditingController: textEditingController,
        );
    }
  }

  Widget _buildTextField({
    required BuildContext context,
    required AdvancedSearchFilterField advancedSearchFilterField,
    TextEditingController? textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
    MouseCursor? mouseCursor,
    FocusNode? currentFocusNode,
    FocusNode? nextFocusNode,
  }) {
    return RawKeyboardListener(
      focusNode: currentFocusNode ?? FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent &&
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
            controller.onSearchAction.call(context);
            popBack();
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: isSelectFormList ? AppColor.colorItemSelected : Colors.white,
          contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              width: isSelectFormList ? 0.5 : 1,
              color: AppColor.colorInputBorderCreateMailbox,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              width: isSelectFormList ? 0.5 : 1,
              color: AppColor.colorInputBorderCreateMailbox,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              width: isSelectFormList ? 0.5 : 1,
              color: AppColor.primaryColor,
            ),
          ),
          hintText: advancedSearchFilterField.getHintText(context),
          hintStyle: TextStyle(
            fontSize: 16,
            color: advancedSearchFilterField == AdvancedSearchFilterField.mailBox
              ? Colors.black
              : AppColor.colorHintSearchBar,
          ),
          suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
          suffixIcon: isSelectFormList
              ? buildIconWeb(
                  icon: SvgPicture.asset(
                    _imagePaths.icDropDown,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
