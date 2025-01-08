
import 'package:core/core.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final bool useIconAsBasicLogo;

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
      this.useIconAsBasicLogo = false,
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
        insetPadding: _outsideDialogPadding,
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
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        margin: _margin,
        padding: const EdgeInsetsDirectional.only(
          top: 8,
          end: 8,
          start: 16,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_onCloseButtonAction != null)
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: TMailButtonWidget.fromIcon(
                  icon: _imagePath.icCancel,
                  iconSize: 24,
                  iconColor: AppColor.steelGrayA540,
                  padding: const EdgeInsets.all(5),
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: _onCloseButtonAction,
                ),
              )
            else
              const SizedBox(height: 24),
            if (useIconAsBasicLogo)
              SvgPicture.asset(
                _imagePath.icTMailLogo,
                fit: BoxFit.fill,
                width: 70,
                height: 70,
              )
            else if (_iconWidget != null)
              Container(
                margin: _marginIcon ?? EdgeInsets.zero,
                alignment: Alignment.center,
                child: _iconWidget,
              ),
            if (_title.isNotEmpty)
              Padding(
                  padding: _paddingTitle
                      ?? const EdgeInsetsDirectional.only(top: 16, end: 8,),
                  child: Center(
                      child: Text(
                          _title,
                          textAlign: TextAlign.center,
                          style: _styleTitle ?? const TextStyle(
                            fontSize: 22.0,
                            color: AppColor.m3SurfaceBackground,
                            fontWeight: FontWeight.w600,
                          )
                      )
                  )
              ),
            if (_textContent.isNotEmpty)
              Padding(
                padding: _paddingContent
                    ?? const EdgeInsetsDirectional.only(top: 16, end: 8,),
                child: Center(
                  child: Text(
                    _textContent,
                    textAlign: TextAlign.center,
                    style: _styleContent ?? const TextStyle(
                      fontSize: 17.0,
                      color: AppColor.steelGrayA540,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else if (listTextSpan != null)
              Padding(
                padding: _paddingContent ??
                    const EdgeInsetsDirectional.only(top: 16, end: 8,),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: _styleContent ?? const TextStyle(
                          fontSize: 17.0,
                          color: AppColor.steelGrayA540,
                          fontWeight: FontWeight.w500,
                        ),
                        children: listTextSpan,
                    ),
                  ),
                ),
              ),
            if (_additionalWidgetContent != null)
              Padding(
                padding:const EdgeInsetsDirectional.only(top: 16, end: 8,),
                child: _additionalWidgetContent,
              ),
            if (isArrangeActionButtonsVertical)
              ...[
                if (_cancelText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 16, end: 8,),
                    child: ConfirmDialogButton(
                        label: _cancelText,
                        backgroundColor: _colorCancelButton ?? AppColor.blue700,
                        borderRadius: _radiusButton,
                        textStyle: _styleTextCancelButton ?? const TextStyle(
                          fontSize: 17,
                          height: 24 / 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        padding: _paddingButton,
                        maxLines: titleActionButtonMaxLines,
                        onTapAction: _onCancelButtonAction),
                  ),
                if (_confirmText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 16, end: 8),
                    child: ConfirmDialogButton(
                        label: _confirmText,
                        backgroundColor: _colorConfirmButton ?? AppColor.colorF3F6F9,
                        borderRadius: _radiusButton,
                        textStyle: _styleTextConfirmButton ?? const TextStyle(
                          fontSize: 17,
                          height: 24 / 17,
                          fontWeight: FontWeight.w500,
                          color: AppColor.steelGray600,
                        ),
                        padding: _paddingButton,
                        maxLines: titleActionButtonMaxLines,
                        onTapAction: _onConfirmButtonAction),
                  ),
              ]
            else
              Padding(
                padding: _marginButton
                    ?? const EdgeInsetsDirectional.only(top: 16, end: 8),
                child: Row(
                  children: [
                    if (_cancelText.isNotEmpty)
                      Expanded(child: ConfirmDialogButton(
                        label: _cancelText,
                        backgroundColor: _colorCancelButton ?? AppColor.blue700,
                        borderRadius: _radiusButton,
                        textStyle: _styleTextCancelButton ?? const TextStyle(
                          fontSize: 17,
                          height: 24 / 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        padding: _paddingButton,
                        maxLines: titleActionButtonMaxLines,
                        onTapAction: _onCancelButtonAction,
                      )),
                    if (_confirmText.isNotEmpty && _cancelText.isNotEmpty)
                      const SizedBox(width: 16),
                    if (_confirmText.isNotEmpty)
                      Expanded(child: ConfirmDialogButton(
                        label: _confirmText,
                        backgroundColor: _colorConfirmButton ?? AppColor.colorF3F6F9,
                        borderRadius: _radiusButton,
                        textStyle: _styleTextConfirmButton ?? const TextStyle(
                          fontSize: 17,
                          height: 24 / 17,
                          fontWeight: FontWeight.w500,
                          color: AppColor.steelGray600,
                        ),
                        padding: _paddingButton,
                        maxLines: titleActionButtonMaxLines,
                        onTapAction: _onConfirmButtonAction,
                      ))
                  ],
                ),
              )
          ],
        ),
    );
  }
}
