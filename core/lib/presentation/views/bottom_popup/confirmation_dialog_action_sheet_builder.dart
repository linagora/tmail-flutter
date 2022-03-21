
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef OnConfirmActionClick = void Function();
typedef OnCancelActionClick = void Function();

class ConfirmationDialogActionSheetBuilder {

  final BuildContext _context;

  String? _messageText;
  String? _confirmText;
  String? _cancelText;
  OnConfirmActionClick?_onConfirmActionClick;
  OnCancelActionClick? _onCancelActionClick;
  TextStyle? _styleConfirmButton;
  TextStyle? _styleCancelButton;
  TextStyle? _styleMessage;

  ConfirmationDialogActionSheetBuilder(this._context);

  void onConfirmAction(String confirmText, OnConfirmActionClick onConfirmActionClick) {
    _onConfirmActionClick = onConfirmActionClick;
    _confirmText = confirmText;
  }

  void onCancelAction(String cancelText, OnCancelActionClick onCancelActionClick) {
    _onCancelActionClick = onCancelActionClick;
    _cancelText = cancelText;
  }

  void messageText(String message) {
    _messageText = message;
  }

  void styleMessage(TextStyle? style) {
    _styleMessage = style;
  }

  void styleConfirmButton(TextStyle? style) {
    _styleConfirmButton = style;
  }

  void styleCancelButton(TextStyle? style) {
    _styleCancelButton = style;
  }

  void show() {
    showCupertinoModalPopup(
      context: _context,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      builder: (context) => PointerInterceptor(child: CupertinoActionSheet(
        actions: [
          Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              color: Colors.white,
              child: CupertinoActionSheetAction(
                child: Text(
                    _messageText ?? '',
                    textAlign: TextAlign.center,
                    style: _styleMessage ?? TextStyle(fontSize: 14, color: AppColor.colorMessageConfirmDialog)),
                onPressed: () => {},
              )
          ),
          Container(
              color: Colors.white,
              child: CupertinoActionSheetAction(
                child: Text(
                    _confirmText ?? '',
                    style: _styleConfirmButton ?? TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: AppColor.colorActionDeleteConfirmDialog)),
                onPressed: () => _onConfirmActionClick?.call(),
              )
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
              _cancelText ?? '',
              style: _styleCancelButton ?? TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: AppColor.colorActionCancelDialog)),
          onPressed: () => _onCancelActionClick?.call(),
        ),
      ))
    );
  }
}