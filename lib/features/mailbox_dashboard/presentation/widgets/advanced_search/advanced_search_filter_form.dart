import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController>
    with PopupContextMenuActionMixin {
  AdvancedSearchInputForm({
    Key? key,
  }) : super(key: key);

  final ImagePaths imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    controller.initSearchFilterField(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Material(
          color: Colors.white,
          child: Column(
            children: [
              _buildFilterField(
                textEditingController: controller.fromFilterInputController,
                context: context,
                advancedSearchFilterField: AdvancedSearchFilterField.form,
              ),
              _buildFilterField(
                textEditingController: controller.toFilterInputController,
                context: context,
                advancedSearchFilterField: AdvancedSearchFilterField.to,
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
              ),
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
              ) ,
              _buildCheckboxHasAttachment(context),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      onAction: () {
                        controller.cleanSearchFilter();
                      },
                      colorButton: AppColor.primaryColor.withOpacity(0.14),
                      colorText: AppColor.primaryColor,
                      text: AppLocalizations.of(context).clearFilter,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildButton(
                      onAction: () {
                        controller.applyAdvancedSearchFilter(context);
                        popBack();
                      },
                      colorButton: AppColor.primaryColor,
                      colorText: AppColor.primaryLightColor,
                      text: AppLocalizations.of(context).search,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmailReceiveTimeTypeActionTiles(BuildContext context) {
    return EmailReceiveTimeType.values
        .map(
          (e) => Material(
        child: PopupMenuItem(
          child: Text(e.getTitle(context)),
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
        width: responsiveUtils.isMobile(context) ? null : 112,
        child: Text(
          advancedSearchFilterField.getTitle(context),
          style: const TextStyle(
            fontSize: 14,
            color: AppColor.colorContentEmail,
          ),
        ),
      ),
      const Padding(padding: EdgeInsets.all(4)),
      responsiveUtils.isMobile(context)
          ? _buildTextField(
        isSelectFormList: isSelectFormList,
        onTap: onTap,
        context: context,
        advancedSearchFilterField: advancedSearchFilterField,
        textEditingController: textEditingController,
      ) : Expanded(
        child: _buildTextField(
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
      child: responsiveUtils.isMobile(context)
          ? Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: child,
      )
          : Row(children: child),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required AdvancedSearchFilterField advancedSearchFilterField,
    required TextEditingController textEditingController,
    VoidCallback? onTap,
    bool isSelectFormList = false,
  }) =>
      TextField(
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
            suffixIconConstraints:
            const BoxConstraints(minHeight: 24, minWidth: 24),
            suffixIcon: isSelectFormList
                ? buildIconWeb(
              icon: SvgPicture.asset(
                imagePaths.icDropDown,
              ),
            )
                : null),
      );

  Widget _buildCheckboxHasAttachment(BuildContext context) {
    return Obx(
      ()=> CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: controller.hasAttachment.value,
        onChanged: (value) {
          controller.hasAttachment.value = value ?? false;
        },
        title: Text(AppLocalizations.of(context).hasAttachment),
      ),
    );
  }

  Widget _buildButton({
    required Color colorButton,
    required Color colorText,
    required String text,
    required VoidCallback onAction,
  }) {
    return InkWell(
      onTap: onAction,
      onTapDown: (_) {
        onAction.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: colorButton),
        child: Text(
          text,
          style: TextStyle(fontSize: 17, color: colorText),
        ),
      ),
    );
  }

  Widget _buildEmailReceiveTimeTypeDropDownButton(){
    return DropdownButtonHideUnderline(
      child: DropdownButton2<EmailReceiveTimeType>(
        isExpanded: true,
        hint: Row(
          children: [
            Expanded(child: Text(controller.dateFilterSelectedFormAdvancedSearch.value.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
              maxLines: 1,
              overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
            )),
          ],
        ),
        items: EmailReceiveTimeType.values.map((item) => DropdownMenuItem<EmailReceiveTimeType>(
          value: item,
          child: Text(
            item.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
            maxLines: 1,
            overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
          ),
        )).toList(),
        value: controller.dateFilterSelectedFormAdvancedSearch.value,
        onChanged: (item) {
          controller.dateFilterSelectedFormAdvancedSearch.value = item!;
        },
        icon: SvgPicture.asset(imagePaths.icDropDown),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
        buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.colorInputBorderCreateMailbox, width: 0.5),
            color: AppColor.colorInputBackgroundCreateMailbox),
        itemHeight: 44,
        buttonHeight: 44,
        selectedItemHighlightColor: Colors.black12,
        itemPadding: const EdgeInsets.symmetric(horizontal: 12),
        dropdownMaxHeight: 200,
        dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white),
        dropdownElevation: 4,
        scrollbarRadius: const Radius.circular(40),
        scrollbarThickness: 6,
      ),
    );
  }
}
