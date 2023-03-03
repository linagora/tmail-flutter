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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form_bottom_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/date_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/text_field_auto_complete_email_adress.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController>
    with PopupContextMenuActionMixin {
  AdvancedSearchInputForm({
    Key? key,
  }) : super(key: key);

  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSuggestionFilterField(
          listTagSelected: controller.searchEmailFilter.from,
          context: context,
          advancedSearchFilterField: AdvancedSearchFilterField.form,
          listTagInitial: controller.searchEmailFilter.from,
          currentFocusNode: controller.focusManager.fromFieldFocusNode,
          nextFocusNode: controller.focusManager.toFieldFocusNode
        ),
        _buildSuggestionFilterField(
          listTagSelected: controller.searchEmailFilter.to,
          context: context,
          advancedSearchFilterField: AdvancedSearchFilterField.to,
          listTagInitial: controller.searchEmailFilter.to,
          currentFocusNode: controller.focusManager.toFieldFocusNode,
          nextFocusNode: controller.focusManager.subjectFieldFocusNode
        ),
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
            onTap: () => controller.selectedMailBox(context)),
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
        AdvancedSearchFilterFormBottomView(focusManager: controller.focusManager)
      ],
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

  Widget _buildSuggestionFilterField({
    required AdvancedSearchFilterField advancedSearchFilterField,
    required BuildContext context,
    required Set<String> listTagSelected,
    required Set<String> listTagInitial,
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
      _responsiveUtils.isMobile(context) || _responsiveUtils.landscapeTabletSupported(context)
          ? TextFieldAutoCompleteEmailAddress(
              optionsBuilder: controller.getAutoCompleteSuggestion,
              advancedSearchFilterField: advancedSearchFilterField,
              initialTags: listTagInitial,
              currentFocusNode: currentFocusNode,
              nextFocusNode: nextFocusNode,
              onAddTag: (value) {
                if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                  controller.searchEmailFilter.from.add(value.trim());
                  controller.lastTextForm.value = '';
                }
                if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                  controller.searchEmailFilter.to.add(value.trim());
                  controller.lastTextTo.value = '';
                }
              },
              onDeleteTag: (tag) {
                if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                  controller.searchEmailFilter.from.remove(tag);
                  controller.lastTextForm.value = '';
                }
                if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                  controller.searchEmailFilter.to.remove(tag);
                  controller.lastTextTo.value = '';
                }
              },
              onChange: (value) {
                if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                  controller.lastTextForm.value = value.trim();
                }
                if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                  controller.lastTextTo.value = value.trim();
                }
              },
            )
          : Expanded(
              child: TextFieldAutoCompleteEmailAddress(
                optionsBuilder: controller.getAutoCompleteSuggestion,
                advancedSearchFilterField: advancedSearchFilterField,
                initialTags: listTagInitial,
                currentFocusNode: currentFocusNode,
                nextFocusNode: nextFocusNode,
                onAddTag: (value) {
                  if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                    controller.searchEmailFilter.from.add(value.trim());
                    controller.lastTextForm.value = '';
                  }
                  if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                    controller.searchEmailFilter.to.add(value.trim());
                    controller.lastTextTo.value = '';
                  }
                },
                onChange: (value) {
                  if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                    controller.lastTextForm.value = value.trim();
                  }
                  if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                    controller.lastTextTo.value = value.trim();
                  }
                },
                onDeleteTag: (tag) {
                  if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                    controller.searchEmailFilter.from.remove(tag);
                    controller.lastTextForm.value = '';
                  }
                  if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                    controller.searchEmailFilter.to.remove(tag);
                    controller.lastTextTo.value = '';
                  }
                },
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
      child: TextField(
        controller: textEditingController,
        readOnly: isSelectFormList,
        mouseCursor: mouseCursor,
        textInputAction: TextInputAction.next,
        onTap: onTap,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColor.loginTextFieldBackgroundColor,
          contentPadding: const EdgeInsets.only(
            right: 8,
            left: 12,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              width: 0.5,
              color: AppColor.colorInputBorderCreateMailbox,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
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
