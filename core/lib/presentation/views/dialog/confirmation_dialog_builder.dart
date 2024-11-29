
import 'package:core/core.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';

typedef OnConfirmButtonAction = void Function();
typedef OnCancelButtonAction = void Function();
typedef OnCloseButtonAction = void Function();

class ConfirmDialogBuilder {
  final ImagePaths _imagePath;

  Key? _key;
  String _title = '';
  String _textContent = '';
  String _confirmText = '';
  String _cancelText = '';
  Widget? _iconWidget;
  Widget? _additionalWidgetContent;
  Color? _colorCancelButton;
  Color? _colorConfirmButton;
  TextStyle? _styleTextCancelButton;
  TextStyle? _styleTextConfirmButton;
  TextStyle? _styleTitle;
  TextStyle? _styleContent;
  double? _radiusButton;
  EdgeInsetsGeometry? _paddingTitle;
  EdgeInsets? _paddingContent;
  EdgeInsetsGeometry? _paddingButton;
  EdgeInsets? _marginButton;
  EdgeInsets? _outsideDialogPadding;
  EdgeInsetsGeometry? _marginIcon;
  EdgeInsets? _margin;
  double? _widthDialog;
  final double maxWith;
  Alignment? _alignment;
  Color? _backgroundColor;
  final bool showAsBottomSheet;
  final List<TextSpan>? listTextSpan;
  final int? titleActionButtonMaxLines;
  final bool isArrangeActionButtonsVertical;

  OnConfirmButtonAction? _onConfirmButtonAction;
  OnCancelButtonAction? _onCancelButtonAction;
  OnCloseButtonAction? _onCloseButtonAction;

  ConfirmDialogBuilder(
    this._imagePath,
    {
      this.showAsBottomSheet = false,
      this.listTextSpan,
      this.maxWith = double.infinity,
      this.titleActionButtonMaxLines,
      this.isArrangeActionButtonsVertical = false,
    }
  );

  void key(Key key) {
    _key = key;
  }

  void title(String title) {
    _title = title;
  }

  void content(String content) {
    _textContent = content;
  }

  void addWidgetContent(Widget? icon) {
    _additionalWidgetContent = icon;
  }

  void addIcon(Widget? icon) {
    _iconWidget = icon;
  }

  void colorCancelButton(Color? color) {
    _colorCancelButton = color;
  }

  void colorConfirmButton(Color? color) {
    _colorConfirmButton = color;
  }

  void styleTextCancelButton(TextStyle? style) {
    _styleTextCancelButton = style;
  }

  void styleTextConfirmButton(TextStyle? style) {
    _styleTextConfirmButton = style;
  }

  void styleTitle(TextStyle? style) {
    _styleTitle = style;
  }

  void styleContent(TextStyle? style) {
    _styleContent = style;
  }

  void radiusButton(double? radius) {
    _radiusButton = radius;
  }

  void paddingTitle(EdgeInsetsGeometry? value) {
    _paddingTitle = value;
  }

  void paddingContent(EdgeInsets? value) {
    _paddingContent = value;
  }

  void paddingButton(EdgeInsetsGeometry? value) {
    _paddingButton = value;
  }

  void marginButton(EdgeInsets? value) {
    _marginButton = value;
  }

  void marginIcon(EdgeInsetsGeometry? value) {
    _marginIcon = value;
  }

  void margin(EdgeInsets? value) {
    _margin = value;
  }

  void widthDialog(double? value) {
    _widthDialog = value;
  }

  void alignment(Alignment? alignment) {
    _alignment = alignment;
  }

  void outsideDialogPadding(EdgeInsets? value) {
    _outsideDialogPadding = value;
  }

  void backgroundColor(Color value) {
    _backgroundColor = value;
  }

  void onConfirmButtonAction(String confirmText, OnConfirmButtonAction? onConfirmButtonAction) {
    _confirmText = confirmText;
    _onConfirmButtonAction = onConfirmButtonAction;
  }

  void onCancelButtonAction(String cancelText, OnCancelButtonAction? onCancelButtonAction) {
    _cancelText = cancelText;
    _onCancelButtonAction = onCancelButtonAction;
  }

  void onCloseButtonAction(OnCloseButtonAction? onCloseButtonAction) {
    _onCloseButtonAction = onCloseButtonAction;
  }

  Widget build() {
    if (showAsBottomSheet) {
      return _bodyContent();
    } else {
      return Dialog(
        key: _key,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
        insetPadding: _outsideDialogPadding ?? const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0),
        alignment: _alignment ?? Alignment.center,
        backgroundColor: _backgroundColor,
        child: _bodyContent(),
      );
    }
  }

  Widget _bodyContent() {
    return Container(
        width: _widthDialog ?? 400,
        constraints: BoxConstraints(maxWidth: maxWith),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(18))),
        margin: _margin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_onCloseButtonAction != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TMailButtonWidget.fromIcon(
                  icon: _imagePath.icCircleClose,
                  iconSize: 30,
                  padding: const EdgeInsets.all(3),
                  backgroundColor: Colors.transparent,
                  margin: const EdgeInsetsDirectional.only(top: 16, end: 16),
                  onTapActionCallback: _onCloseButtonAction
                )
              ),
            if (_iconWidget != null)
              Container(
                margin: _marginIcon ?? EdgeInsets.zero,
                alignment: Alignment.center,
                child: _iconWidget,
              ),
            if (_title.isNotEmpty)
              Padding(
                  padding: _paddingTitle ?? const EdgeInsetsDirectional.only(top: 12, start: 24, end: 24),
                  child: Center(
                      child: Text(
                          _title,
                          textAlign: TextAlign.center,
                          style: _styleTitle ?? const TextStyle(fontSize: 20.0, color: AppColor.colorActionDeleteConfirmDialog, fontWeight: FontWeight.w500)
                      )
                  )
              ),
            if (_textContent.isNotEmpty)
              Padding(
                padding: _paddingContent ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: Text(_textContent,
                      textAlign: TextAlign.center,
                      style: _styleContent ?? const TextStyle(fontSize: 17.0, color: AppColor.colorMessageDialog)
                  ),
                ),
              )
            else if (listTextSpan != null)
              Padding(
                padding: _paddingContent ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: _styleContent ?? const TextStyle(fontSize: 17.0, color: AppColor.colorMessageDialog),
                      children: listTextSpan
                    ),
                  ),
                ),
              ),
            if (_additionalWidgetContent != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _additionalWidgetContent,
              ),
            if (isArrangeActionButtonsVertical)
              ...[
                if (_cancelText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8, start: 16, end: 16),
                    child: ConfirmDialogButton(
                      label: _cancelText,
                      backgroundColor: _colorCancelButton,
                      borderRadius: _radiusButton,
                      textStyle: _styleTextCancelButton,
                      padding: _paddingButton,
                      maxLines: titleActionButtonMaxLines,
                      onTapAction: _onCancelButtonAction),
                  ),
                if (_confirmText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8, start: 16, end: 16),
                    child: ConfirmDialogButton(
                      label: _confirmText,
                      backgroundColor: _colorConfirmButton,
                      borderRadius: _radiusButton,
                      textStyle: _styleTextConfirmButton,
                      padding: _paddingButton,
                      maxLines: titleActionButtonMaxLines,
                      onTapAction: _onConfirmButtonAction),
                  ),
                const SizedBox(height: 16),
              ]
            else
              Padding(
                padding: _marginButton ?? const EdgeInsetsDirectional.only(bottom: 16, start: 16, end: 16),
                child: Row(
                    children: [
                      if (_cancelText.isNotEmpty)
                        Expanded(child: ConfirmDialogButton(
                          label: _cancelText,
                          backgroundColor: _colorCancelButton,
                          borderRadius: _radiusButton,
                          textStyle: _styleTextCancelButton,
                          padding: _paddingButton,
                          maxLines: titleActionButtonMaxLines,
                          onTapAction: _onCancelButtonAction)),
                      if (_confirmText.isNotEmpty && _cancelText.isNotEmpty) const SizedBox(width: 8),
                      if (_confirmText.isNotEmpty)
                        Expanded(child: ConfirmDialogButton(
                          label: _confirmText,
                          backgroundColor: _colorConfirmButton,
                          borderRadius: _radiusButton,
                          textStyle: _styleTextConfirmButton,
                          padding: _paddingButton,
                          maxLines: titleActionButtonMaxLines,
                          onTapAction: _onConfirmButtonAction,))
                    ]
                ))
          ]
        )
    );
  }
}
