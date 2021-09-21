import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/getwidget.dart';

class AppToast {
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
}
