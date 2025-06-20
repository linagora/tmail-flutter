
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
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
  List<TextSpan>? listTextSpan;

  ConfirmationDialogActionSheetBuilder(this._context, {this.listTextSpan});

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

  void styleConfirmButton(TextStyle? style) {
    _styleConfirmButton = style;
  }

  void styleCancelButton(TextStyle? style) {
    _styleCancelButton = style;
  }

  Future<dynamic> show() async {
    return await showCupertinoModalPopup(
      context: _context,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      builder: (context) => PointerInterceptor(child: CupertinoActionSheet(
        actions: [
          if (_messageText != null && _messageText!.isNotEmpty)
            Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                color: Colors.white,
                child: MouseRegion(
                  cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
                  child: CupertinoActionSheetAction(
                    child: Text(
                        _messageText ?? '',
                        textAlign: TextAlign.center,
                        style: ThemeUtils.textStyleM3BodyMedium1,
                    ),
                    onPressed: () => {},
                  ),
                )
            )
          else if (listTextSpan != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              color: Colors.white,
              child: MouseRegion(
                cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
                child: CupertinoActionSheetAction(
                  child: RichText(text: TextSpan(
                    style: ThemeUtils.textStyleM3BodyMedium1,
                    children: listTextSpan
                  )),
                  onPressed: () => {},
                ),
              )
            ),
          Container(
              color: Colors.white,
              child: MouseRegion(
                cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
                child: CupertinoActionSheetAction(
                  child: Text(
                      _confirmText ?? '',
                      style: _styleConfirmButton ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.colorActionDeleteConfirmDialog,
                      )),
                  onPressed: () => _onConfirmActionClick?.call(),
                ),
              )
          ),
        ],
        cancelButton: MouseRegion(
          cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
          child: CupertinoActionSheetAction(
            child: Text(
                _cancelText ?? '',
                style: _styleCancelButton ??  Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColor.blue700,
                )),
            onPressed: () => _onCancelActionClick?.call(),
          ),
        ),
      ))
    );
  }
}