
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnConfirmButtonAction = void Function();
typedef OnCancelButtonAction = void Function();
typedef OnCloseButtonAction = void Function();

class ConfirmDialogBuilder {
  final ImagePaths _imagePath;

  Key? _key;
  String _title = '';
  String _content = '';
  String _confirmText = '';
  String _cancelText = '';
  Widget? _iconWidget;
  Color? _colorCancelButton;
  Color? _colorConfirmButton;
  TextStyle? _styleTextCancelButton;
  TextStyle? _styleTextConfirmButton;
  TextStyle? _styleTitle;
  TextStyle? _styleContent;
  double? _radiusButton;
  double? heightButton;
  EdgeInsets? _paddingTitle;
  EdgeInsets? _paddingContent;
  EdgeInsets? _paddingButton;
  EdgeInsets? _outsideDialogPadding;
  EdgeInsets? _marginIcon;
  EdgeInsets? _margin;
  double? _widthDialog;
  double? _heightDialog;
  Alignment? _alignment;
  Color? _backgroundColor;
  bool showAsBottomSheet;
  List<TextSpan>? listTextSpan;

  OnConfirmButtonAction? _onConfirmButtonAction;
  OnCancelButtonAction? _onCancelButtonAction;
  OnCloseButtonAction? _onCloseButtonAction;

  ConfirmDialogBuilder(
    this._imagePath,
    {
      this.showAsBottomSheet = false,
      this.listTextSpan,
      this.heightButton,
    }
  );

  void key(Key key) {
    _key = key;
  }

  void title(String title) {
    _title = title;
  }

  void content(String content) {
    _content = content;
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

  void paddingTitle(EdgeInsets? value) {
    _paddingTitle = value;
  }

  void paddingContent(EdgeInsets? value) {
    _paddingContent = value;
  }

  void paddingButton(EdgeInsets? value) {
    _paddingButton = value;
  }

  void marginIcon(EdgeInsets? value) {
    _marginIcon = value;
  }

  void margin(EdgeInsets? value) {
    _margin = value;
  }

  void widthDialog(double? value) {
    _widthDialog = value;
  }

  void heightDialog(double? value) {
    _heightDialog = value;
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
            borderRadius: BorderRadius.all(Radius.circular(16))),
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
        height: _heightDialog,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: _margin,
        child: Wrap(children: [
          if (_onCloseButtonAction != null)
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: buildIconWeb(
                        icon: SvgPicture.asset(_imagePath.icCloseMailbox, fit: BoxFit.fill),
                        onTap: () => _onCloseButtonAction?.call())
                )),
          if (_iconWidget != null)
            Container(
              margin: _marginIcon ?? EdgeInsets.zero,
              alignment: Alignment.center,
              child: _iconWidget,
            ),
          if (_title.isNotEmpty)
            Padding(
                padding: _paddingTitle ?? const EdgeInsets.only(top: 12),
                child: Center(
                    child: Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: _styleTitle ?? const TextStyle(fontSize: 20.0, color: AppColor.colorActionDeleteConfirmDialog, fontWeight: FontWeight.w500)
                    )
                )
            ),
          if (_content.isNotEmpty)
            Padding(
              padding: _paddingContent ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: Text(_content,
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
          Padding(
              padding: _paddingButton ?? const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Row(
                  children: [
                    if (_cancelText.isNotEmpty)
                      Expanded(child: _buildButton(
                          name: _cancelText,
                          bgColor: _colorCancelButton,
                          radius: _radiusButton,
                          height: heightButton,
                          textStyle: _styleTextCancelButton,
                          action: _onCancelButtonAction)),
                    if (_confirmText.isNotEmpty && _cancelText.isNotEmpty) const SizedBox(width: 16),
                    if (_confirmText.isNotEmpty)
                      Expanded(child: _buildButton(
                          name: _confirmText,
                          bgColor: _colorConfirmButton,
                          radius: _radiusButton,
                          height: heightButton,
                          textStyle: _styleTextConfirmButton,
                          action: _onConfirmButtonAction))
                  ]
              ))
        ])
    );
  }

  Widget _buildButton({
    String? name,
    TextStyle? textStyle,
    Color? bgColor,
    double? radius,
    double? height,
    Function? action
  }) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: () => action?.call(),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) => bgColor ?? AppColor.colorTextButton),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) => bgColor ?? AppColor.colorTextButton),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 8),
              side: BorderSide(width: 0, color: bgColor ?? AppColor.colorTextButton),
            )),
            padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                    (Set<MaterialState> states) => const EdgeInsets.symmetric(horizontal: 16)),
            elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
        child: Text(name ?? '',
            textAlign: TextAlign.center,
            style: textStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white)),
      )
    );
  }
}
