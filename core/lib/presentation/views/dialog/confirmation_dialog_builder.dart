
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
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                padding: EdgeInsets.only(top: 16, right: 16),
                onPressed: () => _onCloseButtonAction?.call(),
                icon: SvgPicture.asset(_imagePath.icCloseMailbox, width: 30, height: 30, fit: BoxFit.fill))),
          if (_iconWidget != null)
            Container(
              margin: EdgeInsets.only(top: 24),
              alignment: Alignment.center,
              child: _iconWidget,
            ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(
              child: Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, color: AppColor.colorActionDeleteConfirmDialog, fontWeight: FontWeight.w500)
              )
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Text(_content,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17.0, color: AppColor.colorMessageDialog)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                    child: _buildButton(name: _cancelText, action: _onCancelButtonAction)
                ),
                SizedBox(width: 16),
                Expanded(
                    child: _buildButton(
                        name: _confirmText,
                        bgColor: AppColor.colorConfirmActionDialog,
                        nameColor: AppColor.colorActionDeleteConfirmDialog,
                        action: _onConfirmButtonAction)
                )
              ]
            ))
        ])
      ),
    );
  }

  Widget _buildButton({
    String? name, Color? nameColor, Color? bgColor, Function? action
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
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(width: 0, color: bgColor ?? AppColor.colorTextButton),
            )),
            padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                    (Set<MaterialState> states) => EdgeInsets.symmetric(horizontal: 16)),
            elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
        child: Text(name ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: nameColor ?? Colors.white)),
      )
    );
  }
}
