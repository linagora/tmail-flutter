import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
}
