import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/checkbox/labeled_checkbox.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/presentation/views/text/text_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/insert_link_dialog_builder_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenNewTabChanged = void Function(bool? isOpenNewTab);

class InsertLinkDialogBuilder {
  final BuildContext context;
  final ResponsiveUtils responsiveUtils;
  final GlobalKey<FormState> formKey;
  final TextEditingController displayTextFieldController;
  final TextEditingController linkTextFieldController;
  final bool isOpenNewTab;
  final FocusNode displayTextFieldFocusNode;
  final FocusNode linkTextFieldFocusNode;
  final FocusNode openNewTabFocusNode;
  final VoidCallback? cancelActionCallback;
  final VoidCallback? insertActionCallback;
  final OnOpenNewTabChanged? onOpenNewTabChanged;

  const InsertLinkDialogBuilder({
    required this.context,
    required this.responsiveUtils,
    required this.formKey,
    required this.displayTextFieldController,
    required this.linkTextFieldController,
    required this.isOpenNewTab,
    required this.displayTextFieldFocusNode,
    required this.linkTextFieldFocusNode,
    required this.openNewTabFocusNode,
    this.cancelActionCallback,
    this.insertActionCallback,
    this.onOpenNewTabChanged,
  });

  Future<dynamic> show() async {
    return Get.dialog(
      PointerInterceptor(
        child: AlertDialog(
          surfaceTintColor: Colors.white,
          title: Text(
            AppLocalizations.of(context).insertLink,
            textAlign: TextAlign.center,
            style: InsertLinkDialogBuilderStyle.tittleStyle
          ),
          titlePadding: InsertLinkDialogBuilderStyle.tittlePadding,
          contentPadding: InsertLinkDialogBuilderStyle.contentPadding,
          actionsPadding: InsertLinkDialogBuilderStyle.actionsPadding,
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowButtonSpacing: InsertLinkDialogBuilderStyle.actionOverFlowButtonSpacing,
          shape: InsertLinkDialogBuilderStyle.shape,
          scrollable: true,
          elevation: InsertLinkDialogBuilderStyle.elevation,
          content: SizedBox(
            width: responsiveUtils.getSizeScreenWidth(context) * InsertLinkDialogBuilderStyle.widthRatio,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).textToDisplay,
                    style: InsertLinkDialogBuilderStyle.fieldTitleStyle,
                  ),
                  const SizedBox(height: InsertLinkDialogBuilderStyle.tittleToFieldSpace),
                  TextFieldBuilder(
                    controller: displayTextFieldController,
                    focusNode: displayTextFieldFocusNode,
                    textInputAction: TextInputAction.next,
                    maxLines: InsertLinkDialogBuilderStyle.maxLines,
                    textStyle: InsertLinkDialogBuilderStyle.textInputStyle,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: InsertLinkDialogBuilderStyle.textInputContentPadding,
                      enabledBorder: InsertLinkDialogBuilderStyle.border,
                      border: InsertLinkDialogBuilderStyle.border,
                      focusedBorder: InsertLinkDialogBuilderStyle.focusedBorder,
                      hintText: AppLocalizations.of(context).textToDisplay,
                      hintStyle: InsertLinkDialogBuilderStyle.hintTextStyle,
                    ),
                  ),
                  const SizedBox(height: InsertLinkDialogBuilderStyle.fieldToFieldSpace),
                  Text(
                    AppLocalizations.of(context).toWhatURLShouldThisLinkGo,
                    style: InsertLinkDialogBuilderStyle.fieldTitleStyle,
                  ),
                  const SizedBox(height: InsertLinkDialogBuilderStyle.tittleToFieldSpace),
                  TextFormFieldBuilder(
                    controller: linkTextFieldController,
                    focusNode: linkTextFieldFocusNode,
                    textInputAction: TextInputAction.done,
                    textStyle: InsertLinkDialogBuilderStyle.textInputStyle,
                    decoration: InsertLinkDialogBuilderStyle.urlFieldDecoration,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).pleaseEnterURL;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: InsertLinkDialogBuilderStyle.fieldToFieldSpace),
                  LabeledCheckbox(
                    label: AppLocalizations.of(context).openInNewTab,
                    value: isOpenNewTab,
                    onChanged: onOpenNewTabChanged,
                    focusNode: openNewTabFocusNode,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColor.primaryColor,
                  )
                ],
              ),
            ),
          ),
          actions: [
            buildButtonWrapText(
              AppLocalizations.of(context).cancel,
              radius: InsertLinkDialogBuilderStyle.buttonRadius,
              height: InsertLinkDialogBuilderStyle.buttonHeight,
              bgColor: AppColor.colorBgSearchBar,
              textStyle: InsertLinkDialogBuilderStyle.buttonCancelTextStyle,
              onTap: cancelActionCallback,
            ),
            buildButtonWrapText(
              AppLocalizations.of(context).insert,
              radius: InsertLinkDialogBuilderStyle.buttonRadius,
              height: InsertLinkDialogBuilderStyle.buttonHeight,
              textStyle: InsertLinkDialogBuilderStyle.buttonInsertTextStyle,
              bgColor: AppColor.primaryColor,
              onTap: insertActionCallback,
            ),
          ],
        )
      )
    );
  }
}