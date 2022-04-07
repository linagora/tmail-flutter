
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
      Function onConfirmAction,
      {bool hasCancelButton = true, Widget? icon}
  ) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(message)
        ..styleConfirmButton(TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(actionName, () {
          popBack();
          onConfirmAction.call();
        })).show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(Key('confirm_dialog_action'))
              ..title(AppLocalizations.of(context).sending_failed)
              ..content(message)
              ..addIcon(icon)
              ..colorConfirmButton(AppColor.colorTextButton)
              ..colorCancelButton(AppColor.colorCancelButton)
              ..paddingTitle(icon != null ? EdgeInsets.only(top: 34) : EdgeInsets.only(top: 10))
              ..marginIcon(EdgeInsets.zero)
              ..paddingContent(EdgeInsets.only(left: 44, right: 44, bottom: 24, top: 8))
              ..paddingButton(hasCancelButton ? null : EdgeInsets.only(bottom: 16, left: 44, right: 44))
              ..styleTitle(TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
              ..styleContent(TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
              ..styleTextCancelButton(TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
              ..styleTextConfirmButton(TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
              ..onConfirmButtonAction(actionName, () {
                popBack();
                onConfirmAction.call();
              })
              ..onCancelButtonAction(hasCancelButton ? AppLocalizations.of(context).cancel : '', () => popBack())
              ..onCloseButtonAction(() => popBack()))
            .build()));
    }
  }
}