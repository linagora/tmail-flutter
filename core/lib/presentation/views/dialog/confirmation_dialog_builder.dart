
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
  EdgeInsets? _paddingTitle;
  EdgeInsets? _paddingContent;
  EdgeInsets? _paddingButton;
  EdgeInsets? _marginIcon;

  OnConfirmButtonAction? _onConfirmButtonAction;
  OnCancelButtonAction? _onCancelButtonAction;
  OnCloseButtonAction? _onCloseButtonAction;

  ConfirmDialogBuilder(this._imagePath);

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
    return Dialog(
      key: _key,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        width: 400,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Wrap(children: [
          if (_onCloseButtonAction != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(top: 8, right: 8),
                child: buildIconWeb(
                    icon: SvgPicture.asset(_imagePath.icCloseMailbox, fit: BoxFit.fill),
                    onTap: () => _onCloseButtonAction?.call())
              )),
          if (_iconWidget != null)
            Container(
              margin: _marginIcon ?? EdgeInsets.only(top: 24),
              alignment: Alignment.center,
              child: _iconWidget,
            ),
          if (_title.isNotEmpty)
            Padding(
              padding: _paddingTitle ?? EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: _styleTitle ?? TextStyle(fontSize: 20.0, color: AppColor.colorActionDeleteConfirmDialog, fontWeight: FontWeight.w500)
                )
              )
            ),
          if (_content.isNotEmpty)
            Padding(
              padding: _paddingContent ?? EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: Text(_content,
                  textAlign: TextAlign.center,
                  style: _styleContent ?? TextStyle(fontSize: 17.0, color: AppColor.colorMessageDialog)
                ),
              ),
            ),
          Padding(
            padding: _paddingButton ?? EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Row(
              children: [
                if (_cancelText.isNotEmpty)
                  Expanded(child: _buildButton(
                    name: _cancelText,
                    bgColor: _colorCancelButton,
                    radius: _radiusButton,
                    textStyle: _styleTextCancelButton,
                    action: _onCancelButtonAction)),
                if (_confirmText.isNotEmpty && _cancelText.isNotEmpty) SizedBox(width: 16),
                if (_confirmText.isNotEmpty)
                  Expanded(child: _buildButton(
                    name: _confirmText,
                    bgColor: _colorConfirmButton,
                    radius: _radiusButton,
                    textStyle: _styleTextConfirmButton,
                    action: _onConfirmButtonAction))
              ]
            ))
        ])
      ),
    );
  }

  Widget _buildButton({
    String? name, TextStyle? textStyle, Color? bgColor, double? radius, Function? action
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
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
                    (Set<MaterialState> states) => EdgeInsets.symmetric(horizontal: 16)),
            elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
        child: Text(name ?? '',
            textAlign: TextAlign.center,
            style: textStyle ?? TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white)),
      )
    );
  }
}
