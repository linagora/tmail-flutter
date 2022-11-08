
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin MessageDialogActionMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  void showConfirmDialogAction(
      BuildContext context,
      String message,
      String actionName,
      {
        Function? onConfirmAction,
        String? title,
        String? cancelTitle,
        bool hasCancelButton = true,
        bool showAsBottomSheet = false,
        Widget? icon,
        TextStyle? titleStyle,
        TextStyle? actionStyle,
        TextStyle? cancelStyle,
        Color? actionButtonColor,
        Color? cancelButtonColor,
      }
  ) {
    if (_responsiveUtils.isMobile(context)) {
      if (showAsBottomSheet) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            barrierColor: AppColor.colorDefaultCupertinoActionSheet,
            backgroundColor: Colors.transparent,
            enableDrag: true,
            builder: (BuildContext context) => PointerInterceptor(
              child: (ConfirmDialogBuilder(_imagePaths, showAsBottomSheet: true)
                ..key(const Key('confirm_dialog_action'))
                ..title(title ?? '')
                ..content(message)
                ..addIcon(icon)
                ..margin(const EdgeInsets.symmetric(vertical: 42, horizontal: 16))
                ..widthDialog(_responsiveUtils.getSizeScreenWidth(context))
                ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
                ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
                ..paddingTitle(icon != null ? const EdgeInsets.only(top: 24) : EdgeInsets.zero)
                ..marginIcon(EdgeInsets.zero)
                ..paddingContent(const EdgeInsets.only(left: 44, right: 44, bottom: 24, top: 12))
                ..paddingButton(hasCancelButton ? null : const EdgeInsets.only(bottom: 16, left: 44, right: 44))
                ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
                ..styleContent(const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
                ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
                ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
                ..onConfirmButtonAction(actionName, () {
                  popBack();
                  onConfirmAction?.call();
                })
                ..onCancelButtonAction(hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '', () => popBack())
                ..onCloseButtonAction(() => popBack()))
              .build()));
      } else {
        (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(message)
          ..styleConfirmButton(const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black))
          ..onCancelAction(cancelTitle ?? AppLocalizations.of(context).cancel, () => popBack())
          ..onConfirmAction(actionName, () {
            popBack();
            onConfirmAction?.call();
          })).show();
      }
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('confirm_dialog_action'))
              ..title(title ?? '')
              ..content(message)
              ..addIcon(icon)
              ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
              ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
              ..paddingTitle(icon != null ? const EdgeInsets.only(top: 24) : EdgeInsets.zero)
              ..marginIcon(EdgeInsets.zero)
              ..paddingContent(const EdgeInsets.only(left: 44, right: 44, bottom: 24, top: 12))
              ..paddingButton(hasCancelButton ? null : const EdgeInsets.only(bottom: 16, left: 44, right: 44))
              ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
              ..styleContent(const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
              ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
              ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
              ..onConfirmButtonAction(actionName, () {
                popBack();
                onConfirmAction?.call();
              })
              ..onCancelButtonAction(hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '', () => popBack())
              ..onCloseButtonAction(() => popBack()))
            .build()));
    }
  }
}