import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnSearchEmail = VoidCallback;

class AdvancedSearchInputForm extends StatelessWidget
    with PopupContextMenuActionMixin {
  AdvancedSearchInputForm(
    this._onSearchEmail, {
    Key? key,
  }) : super(key: key);

  final controller = Get.find<SearchController>();
  final _imagePaths = Get.find<ImagePaths>();
  final OnSearchEmail? _onSearchEmail;

  @override
  Widget build(BuildContext context) {
    controller.initSearchFilterField(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Obx(
          () => Column(
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
                textEditingController:
                    controller.hasKeyWordFilterInputController,
                context: context,
                advancedSearchFilterField: AdvancedSearchFilterField.hasKeyword,
              ),
              _buildFilterField(
                textEditingController:
                    controller.notKeyWordFilterInputController,
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
              ),
              _buildCheckboxHasAttachment(context),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      onAction: () {
                        controller.cleanSearchFilter();
                        _onSearchEmail?.call();
                        popBack();
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
                        controller.updateFilterEmailFromAdvancedSearchView();
                        _onSearchEmail?.call();
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            advancedSearchFilterField.getTitle(context),
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.colorContentEmail,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: TextField(
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
                            _imagePaths.icDropDown,
                          ),
                        )
                      : null),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCheckboxHasAttachment(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: controller.hasAttachmentFilterSelectedFormAdvancedSearch.value,
      onChanged: (value) {
        controller.hasAttachmentFilterSelectedFormAdvancedSearch.value =
            value ?? false;
      },
      title: Text(
        AppLocalizations.of(context).hasAttachment,
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
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: colorButton),
        child: Text(
          text,
          style: TextStyle(fontSize: 17, color: colorText),
        ),
      ),
    );
  }
}
