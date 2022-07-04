import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form_bottom_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/drop_down_button_filter_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/text_field_auto_complete_email_adress.dart';

class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController>
    with PopupContextMenuActionMixin {
  AdvancedSearchInputForm({
    Key? key,
  }) : super(key: key);

  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          _buildSuggestionFilterField(
            listTagSelected: controller.searchEmailFilter.from,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.form,
            listTagInitial: controller.searchEmailFilter.from,
          ),
          _buildSuggestionFilterField(
            listTagSelected: controller.searchEmailFilter.to,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.to,
            listTagInitial: controller.searchEmailFilter.to,
          ),
          _buildFilterField(
            textEditingController: controller.subjectFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.subject,
          ),
          _buildFilterField(
            textEditingController: controller.hasKeyWordFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.hasKeyword,
          ),
          _buildFilterField(
            textEditingController: controller.notKeyWordFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.notKeyword,
          ),
          _buildFilterField(
              textEditingController: controller.mailBoxFilterInputController,
              context: context,
              advancedSearchFilterField: AdvancedSearchFilterField.mailBox,
              isSelectFormList: true,
              onTap: () async {
                await controller.selectedMailBox();
              }),
          _buildFilterField(
            textEditingController: controller.dateFilterInputController,
            context: context,
            advancedSearchFilterField: AdvancedSearchFilterField.date,
            isSelectFormList: true,
            onTap: () {
              openContextMenuAction(
                context,
                _buildEmailReceiveTimeTypeActionTiles(context),
              );
            },
          ),
          const AdvancedSearchFilterFormBottomView()
        ],
      ),
    );
  }

  List<Widget> _buildEmailReceiveTimeTypeActionTiles(BuildContext context) {
    return EmailReceiveTimeType.values
        .map(
          (e) => Material(
            child: PopupMenuItem(
              child: Row(children: [
                const SizedBox(width: 12),
                Expanded(
                    child: Text(e.getTitle(context),
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w500))),
                if (e == controller.dateFilterSelectedFormAdvancedSearch.value)
                ...[
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    _imagePaths.icFilterSelected,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill,
                  ),
                ]
              ]),
              onTap: () {
                controller.dateFilterSelectedFormAdvancedSearch.value = e;
                controller.dateFilterInputController.text = e.getTitle(context);
              },
            ),
          ),
        )
        .toList();
  }

  Widget _buildFilterField({
    required BuildContext context,
    required AdvancedSearchFilterField advancedSearchFilterField,
    required TextEditingController textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
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
          advancedSearchFilterField: advancedSearchFilterField,
          textEditingController: textEditingController,
        )
      else if (_responsiveUtils.landscapeTabletSupported(context))
        if (advancedSearchFilterField == AdvancedSearchFilterField.date)
          const DateDropDownButton()
        else
          _buildTextField(
            isSelectFormList: isSelectFormList,
            onTap: onTap,
            context: context,
            advancedSearchFilterField: advancedSearchFilterField,
            textEditingController: textEditingController,
          )
      else
        Expanded(
          child: _buildTextFieldFilterForWeb(
            isSelectFormList: isSelectFormList,
            onTap: onTap,
            context: context,
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
    required TextEditingController textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
  }) {
    switch (advancedSearchFilterField) {
      case AdvancedSearchFilterField.date:
        return const DateDropDownButton();
      default:
        return _buildTextField(
          isSelectFormList: isSelectFormList,
          onTap: onTap,
          context: context,
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
              optionsBuilder: (word) async {
                return controller.getAutoCompleteSuggestion(word: word);
              },
              advancedSearchFilterField: advancedSearchFilterField,
              initialTags: listTagInitial,
              onAddTag: (value) {
                if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                  controller.searchEmailFilter.from.add(value);
                }
                if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                  controller.searchEmailFilter.to.add(value);
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
                  controller.lastTextForm.value = value;
                }
                if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                  controller.lastTextTo.value = value;
                }
              },
            )
          : Expanded(
              child: TextFieldAutoCompleteEmailAddress(
                optionsBuilder: (word) async {
                  return controller.getAutoCompleteSuggestion(word: word);
                },
                advancedSearchFilterField: advancedSearchFilterField,
                initialTags: listTagInitial,
                onAddTag: (value) {
                  if (advancedSearchFilterField == AdvancedSearchFilterField.form) {
                    controller.searchEmailFilter.from.add(value.trim());
                  }
                  if (advancedSearchFilterField == AdvancedSearchFilterField.to) {
                    controller.searchEmailFilter.to.add(value.trim());
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
    required TextEditingController textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
  }) {
    return TextField(
      controller: textEditingController,
      readOnly: isSelectFormList,
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
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColor.colorHintSearchBar,
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
    );
  }
}
