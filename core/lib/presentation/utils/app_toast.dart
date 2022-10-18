import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

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

  void showSuccessToast(String message, {bool isToastLengthLong = false}) {
    Fluttertoast.showToast(
        msg: message,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        toastLength: isToastLengthLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void showErrorToast(String message, {bool isToastLengthLong = false}) {
    Fluttertoast.showToast(
        msg: message,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: AppColor.toastErrorBackgroundColor,
        toastLength: isToastLengthLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void showBottomToast(
      BuildContext context,
      String message,
      {
        String? actionName,
        Function? onActionClick,
        Widget? actionIcon,
        Widget? leadingIcon,
        double? maxWidth,
        bool infinityToast = false,
        Color? backgroundColor,
        Color? textColor,
        Color? textActionColor,
      }
  ) {
    var trailingAction;

    if (actionName != null) {
      if (actionIcon == null) {
        trailingAction = TextButton(
          onPressed: () {
            ToastView.dismiss();
            onActionClick?.call();
          },
          child: Text(
            actionName,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: textActionColor ?? AppColor.buttonActionToastWithActionColor),
          ),
        );
      } else {
        trailingAction = Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                ToastView.dismiss();
                onActionClick?.call();
              },
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      actionIcon,
                      Text(
                        actionName,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: textActionColor ?? Colors.white),
                      )
                    ]
                ),
              )),
        );
      }
    }

    showToastMessage(
        context,
        message,
        maxWidth: maxWidth,
        backgroundColor: backgroundColor,
        infinityToast: infinityToast,
        textColor: textColor,
        leading: leadingIcon,
        trailing: trailingAction);
  }

  void showToastMessage(
    BuildContext context,
    String message, {
    Color? textColor,
    Widget? leading,
    bool infinityToast = false,
    Widget? trailing,
    double? maxWidth,
    Color? backgroundColor
  }) {
    TMailToast.showToast(
        message,
        context,
        width: maxWidth,
        toastPosition: ToastPosition.BOTTOM,
        textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: textColor ?? Colors.white),
        backgroundColor: backgroundColor ?? AppColor.toastWithActionBackgroundColor,
        trailing: trailing != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: PointerInterceptor(child: trailing))
          : null,
        leading: leading != null
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PointerInterceptor(child: leading))
            : null,
        toastBorderRadius: 10.0,
        toastDuration: infinityToast ? null : 3,
    );
  }

  void showToastWithIcon(BuildContext context, {
      String? message, String? icon, Color? bgColor, Color? iconColor,
      Color? textColor, double? radius, EdgeInsets? padding,
      TextStyle? textStyle, double? widthToast, Duration? toastLength}) {
    double sizeWidth = context.width > 360 ? 360 : context.width - 40;
    final toast = Material(
      color: bgColor ?? Colors.white,
      elevation: 10,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 10.0),
          color: bgColor ?? Colors.white,
        ),
        width: widthToast ?? sizeWidth,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              SvgPicture.asset(icon,
                  width: 24,
                  height: 24,
                  fit: BoxFit.fill,
                  color: iconColor),
            if (icon != null)
              SizedBox(width: 10.0),
            Expanded(child: Text(
                message ?? '',
                style: textStyle ?? TextStyle(fontSize: 15, color: textColor ?? Colors.black))),
          ],
        ),
      ),
    );
    fToast.init(context);
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: toastLength ?? Duration(seconds: 3),
    );
  }
}
