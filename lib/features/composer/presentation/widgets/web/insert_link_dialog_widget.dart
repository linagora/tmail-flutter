import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/checkbox/labeled_checkbox.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/presentation/views/text/text_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/insert_link_dialog_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class InsertLinkDialogWidget extends StatefulWidget {
  final ResponsiveUtils responsiveUtils;
  final HtmlEditorController editorController;
  final String linkTagId;
  final String displayText;
  final String link;
  final bool openNewTab;
  
  const InsertLinkDialogWidget({
    super.key,
    required this.responsiveUtils,
    required this.editorController,
    required this.linkTagId,
    required this.displayText,
    required this.link,
    required this.openNewTab,
  });

  @override
  State<InsertLinkDialogWidget> createState() => _InsertLinkDialogState();
}

class _InsertLinkDialogState extends State<InsertLinkDialogWidget> {
  late FocusNode _displayTextFieldFocusNode;
  late FocusNode _linkTextFieldFocusNode;
  late FocusNode _openNewTabFocusNode;
  late TextEditingController _displayTextFieldController;
  late TextEditingController _linkTextFieldController;
  late HtmlToolbarOptions _htmlToolbarOptions;
  late GlobalKey<FormState> _formKey;
  late bool _openNewTab;

  @override
  void initState() {
    super.initState();
    _displayTextFieldFocusNode = FocusNode();
    _linkTextFieldFocusNode = FocusNode();
    _openNewTabFocusNode = FocusNode();
    _htmlToolbarOptions = const HtmlToolbarOptions();
    _formKey = GlobalKey<FormState>();
    _displayTextFieldController = TextEditingController(text: widget.displayText);
    _linkTextFieldController = TextEditingController(text: widget.link);
    _openNewTab = widget.openNewTab;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      title: Text(
        AppLocalizations.of(context).insertLink,
        textAlign: TextAlign.center,
        style: InsertLinkDialogWidgetStyle.tittleStyle
      ),
      titlePadding: InsertLinkDialogWidgetStyle.tittlePadding,
      contentPadding: InsertLinkDialogWidgetStyle.contentPadding,
      actionsPadding: InsertLinkDialogWidgetStyle.actionsPadding,
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowButtonSpacing: InsertLinkDialogWidgetStyle.actionOverFlowButtonSpacing,
      shape: InsertLinkDialogWidgetStyle.shape,
      scrollable: true,
      elevation: InsertLinkDialogWidgetStyle.elevation,
      content: SizedBox(
        width: widget.responsiveUtils.getSizeScreenWidth(context) * InsertLinkDialogWidgetStyle.widthRatio,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).textToDisplay,
                style: InsertLinkDialogWidgetStyle.fieldTitleStyle,
              ),
              const SizedBox(height: InsertLinkDialogWidgetStyle.tittleToFieldSpace),
              TextFieldBuilder(
                controller: _displayTextFieldController,
                focusNode: _displayTextFieldFocusNode,
                textInputAction: TextInputAction.next,
                maxLines: InsertLinkDialogWidgetStyle.maxLines,
                textStyle: InsertLinkDialogWidgetStyle.textInputStyle,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: InsertLinkDialogWidgetStyle.textInputContentPadding,
                  enabledBorder: InsertLinkDialogWidgetStyle.border,
                  border: InsertLinkDialogWidgetStyle.border,
                  focusedBorder: InsertLinkDialogWidgetStyle.focusedBorder,
                  hintText: AppLocalizations.of(context).textToDisplay,
                  hintStyle: InsertLinkDialogWidgetStyle.hintTextStyle,
                ),
              ),
              const SizedBox(height: InsertLinkDialogWidgetStyle.fieldToFieldSpace),
              Text(
                AppLocalizations.of(context).toWhatURLShouldThisLinkGo,
                style: InsertLinkDialogWidgetStyle.fieldTitleStyle,
              ),
              const SizedBox(height: InsertLinkDialogWidgetStyle.tittleToFieldSpace),
              TextFormFieldBuilder(
                controller: _linkTextFieldController,
                focusNode: _linkTextFieldFocusNode,
                textInputAction: TextInputAction.done,
                textStyle: InsertLinkDialogWidgetStyle.textInputStyle,
                decoration: InsertLinkDialogWidgetStyle.urlFieldDecoration,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterURL;
                  }
                  return null;
                },
              ),
              const SizedBox(height: InsertLinkDialogWidgetStyle.fieldToFieldSpace),
              LabeledCheckbox(
                label: AppLocalizations.of(context).openInNewTab,
                value: _openNewTab,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _openNewTab = value;
                    });
                  }
                },
                focusNode: _openNewTabFocusNode,
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
          radius: InsertLinkDialogWidgetStyle.buttonRadius,
          height: InsertLinkDialogWidgetStyle.buttonHeight,
          bgColor: AppColor.colorBgSearchBar,
          textStyle: InsertLinkDialogWidgetStyle.buttonCancelTextStyle,
          onTap: () => Get.back(),
        ),
        buildButtonWrapText(
          AppLocalizations.of(context).insert,
          radius: InsertLinkDialogWidgetStyle.buttonRadius,
          height: InsertLinkDialogWidgetStyle.buttonHeight,
          textStyle: InsertLinkDialogWidgetStyle.buttonInsertTextStyle,
          bgColor: AppColor.primaryColor,
          onTap: () async {
            if (_formKey.currentState != null && _formKey.currentState!.validate()) {
              var proceed = await _htmlToolbarOptions.linkInsertInterceptor?.call(
                _displayTextFieldController.text.isEmpty
                  ? _linkTextFieldController.text
                  : _displayTextFieldController.text,
                _linkTextFieldController.text,
                _openNewTab,
              ) ?? true;
              if (proceed) {
                widget.editorController.updateLink(
                  _displayTextFieldController.text.isEmpty
                    ? _linkTextFieldController.text
                    : _displayTextFieldController.text,
                  _linkTextFieldController.text,
                  _openNewTab,
                  widget.linkTagId
                );
              }
              Get.back();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _displayTextFieldFocusNode.dispose();
    _linkTextFieldFocusNode.dispose();
    _openNewTabFocusNode.dispose();
    _displayTextFieldController.dispose();
    _linkTextFieldController.dispose();
    super.dispose();
  }
}