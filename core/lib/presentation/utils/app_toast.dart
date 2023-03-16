import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/toast/tmail_toast.dart';
import 'package:core/presentation/views/toast/toast_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class AppToast {

  void showToastErrorMessage(
    BuildContext context,
    String message,
    {
      Color? leadingSVGIconColor,
      String? leadingSVGIcon
    }
  ) {
    final imagePaths = Get.find<ImagePaths>();
    showToastMessage(
      context,
      message,
      backgroundColor: AppColor.toastErrorBackgroundColor,
      textColor: Colors.white,
      leadingSVGIconColor: leadingSVGIconColor ?? (leadingSVGIcon == null ? Colors.white : null),
      leadingSVGIcon: leadingSVGIcon ?? imagePaths.icNotConnection
    );
  }

  void showToastSuccessMessage(
    BuildContext context,
    String message,
    {
      Color? leadingSVGIconColor,
      String? leadingSVGIcon,
    }
  ) {
    final imagePaths = Get.find<ImagePaths>();
    showToastMessage(
      context,
      message,
      backgroundColor: AppColor.toastSuccessBackgroundColor,
      textColor: Colors.white,
      leadingSVGIconColor: leadingSVGIconColor ?? (leadingSVGIcon == null ? Colors.white : null),
      leadingSVGIcon: leadingSVGIcon ?? imagePaths.icToastSuccessMessage
    );
  }

  void showToastMessage(
    BuildContext context,
    String message,
    {
      String? actionName,
      Function? onActionClick,
      Widget? actionIcon,
      Widget? leadingIcon,
      String? leadingSVGIcon,
      Color? leadingSVGIconColor,
      double? maxWidth,
      bool infinityToast = false,
      Color? backgroundColor,
      Color? textColor,
      Color? textActionColor,
      TextStyle? textStyle,
      EdgeInsets? padding,
    }
  ) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    Widget? trailingWidget;
    if (actionName != null) {
      if (actionIcon == null) {
        trailingWidget = PointerInterceptor(
          child: TextButton(
            onPressed: () {
              ToastView.dismiss();
              onActionClick?.call();
            },
            child: Text(
              actionName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: textActionColor ?? Colors.white
              ),
            ),
          ),
        );
      } else {
        trailingWidget = PointerInterceptor(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ToastView.dismiss();
                onActionClick?.call();
              },
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    actionIcon,
                    Text(
                      actionName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: textActionColor ?? Colors.white
                      ),
                    )
                  ]
                ),
              )
            ),
          ),
        );
      }
    }

    Widget? leadingWidget;
    if (leadingIcon != null) {
      leadingWidget = PointerInterceptor(child: leadingIcon);
    } else {
      if (leadingSVGIcon != null) {
        leadingWidget = PointerInterceptor(
          child: SvgPicture.asset(
            leadingSVGIcon,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
            colorFilter: leadingSVGIconColor?.asFilter(),
          )
        );
      }
    }

    TMailToast.showToast(
      message,
      context,
      width: maxWidth ?? responsiveUtils.getMaxWidthToast(context),
      toastPosition: ToastPosition.BOTTOM,
      textStyle: textStyle ?? TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: textColor ?? AppColor.primaryColor
      ),
      backgroundColor: backgroundColor ?? Colors.white,
      trailing: trailingWidget,
      leading: leadingWidget,
      padding: padding,
      toastDuration: infinityToast ? null : 3,
    );
  }
}
