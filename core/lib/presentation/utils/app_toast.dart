import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';

class AppToast {
  final fToast = Get.find<FToast>();

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: AppColor.toastBackgroundColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void showSuccessToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: AppColor.toastErrorBackgroundColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void showToastWithAction(BuildContext context, String message, String actionName, Function onActionClick) {
    GFToast.showToast(
      message,
      context,
      toastPosition: GFToastPosition.BOTTOM,
      textStyle: TextStyle(fontSize: 16, color: Colors.white),
      backgroundColor: AppColor.toastWithActionBackgroundColor,
      trailing: GFButton(
        onPressed: () {
          ToastView.dismiss();
          onActionClick();
        },
        text: actionName,
        type: GFButtonType.transparent,
        color: AppColor.buttonActionToastWithActionColor,
      ),
      toastBorderRadius: 5.0,
      toastDuration: 3
    );
  }

  void showToastWithIcon(BuildContext context,
      {String? message, String? icon, Color? bgColor, double? radius, EdgeInsets? padding, TextStyle? textStyle}) {
    final toast = Material(
      color: bgColor ?? Colors.white,
      elevation: 10,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 10.0),
          color: Colors.white,
        ),
        width: 320,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) SvgPicture.asset(icon, width: 24, height: 24, fit: BoxFit.fill),
            SizedBox(width: 10.0),
            Expanded(child: Text(
                message ?? '',
                style: textStyle ?? TextStyle(fontSize: 15, color: Colors.black))),
          ],
        ),
      ),
    );
    fToast.init(context);
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}
