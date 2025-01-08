
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin MessageDialogActionMixin {

  Future<dynamic> showConfirmDialogAction(
      BuildContext context,
      String message,
      String actionName,
      {
        Key key = const Key('confirm_dialog_action'),
        Function? onConfirmAction,
        Function? onCancelAction,
        OnCloseButtonAction? onCloseButtonAction,
        String? title,
        String? cancelTitle,
        bool hasCancelButton = true,
        bool showAsBottomSheet = false,
        bool alignCenter = false,
        bool outsideDismissible = true,
        bool autoPerformPopBack = true,
        bool usePopScope = false,
        List<TextSpan>? listTextSpan,
        Widget? icon,
        TextStyle? titleStyle,
        TextStyle? messageStyle,
        TextStyle? actionStyle,
        TextStyle? cancelStyle,
        Color? actionButtonColor,
        Color? cancelButtonColor,
        EdgeInsetsGeometry? marginIcon,
        EdgeInsetsGeometry? paddingButton,
        PopInvokedWithResultCallback? onPopInvoked,
        bool isArrangeActionButtonsVertical = false,
        int? titleActionButtonMaxLines,
        bool useIconAsBasicLogo = false,
      }
  ) async {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final imagePaths = Get.find<ImagePaths>();

    if (alignCenter) {
      final childWidget = PointerInterceptor(
        child: (ConfirmDialogBuilder(
            imagePaths,
            listTextSpan: listTextSpan,
            titleActionButtonMaxLines: titleActionButtonMaxLines,
            isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
            useIconAsBasicLogo: useIconAsBasicLogo,
          )
          ..key(key)
          ..title(title ?? '')
          ..content(message)
          ..addIcon(icon)
          ..colorConfirmButton(actionButtonColor ?? AppColor.blue700)
          ..colorCancelButton(cancelButtonColor ?? AppColor.colorF3F6F9)
          ..radiusButton(12)
          ..styleTitle(titleStyle)
          ..styleContent(messageStyle)
          ..styleTextCancelButton(cancelStyle ?? const TextStyle(
            fontSize: 17,
            height: 24 / 17,
            fontWeight: FontWeight.w500,
            color: AppColor.steelGray600,
          ))
          ..styleTextConfirmButton(actionStyle ?? const TextStyle(
            fontSize: 17,
            height: 24 / 17,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ))
          ..onConfirmButtonAction(actionName, () {
            if (autoPerformPopBack) {
              popBack();
            }
            onConfirmAction?.call();
          })
          ..onCancelButtonAction(
              hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
                  () {
                if (autoPerformPopBack) {
                  popBack();
                }
                onCancelAction?.call();
              }
          )
          ..onCloseButtonAction(onCloseButtonAction)
        ).build()
      );
      return await Get.dialog(
        usePopScope && PlatformInfo.isMobile
          ? PopScope(onPopInvokedWithResult: onPopInvoked, canPop: false, child: childWidget)
          : childWidget,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        barrierDismissible: outsideDismissible
      );
    } else {
      if (responsiveUtils.isMobile(context)) {
        final childWidget = PointerInterceptor(
          child: (ConfirmDialogBuilder(
              imagePaths,
              showAsBottomSheet: true,
              listTextSpan: listTextSpan,
              maxWith: responsiveUtils.getSizeScreenShortestSide(context) - 16,
              titleActionButtonMaxLines: titleActionButtonMaxLines,
              isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
              useIconAsBasicLogo: useIconAsBasicLogo,
            )
            ..key(key)
            ..title(title ?? '')
            ..content(message)
            ..addIcon(icon)
            ..widthDialog(responsiveUtils.getSizeScreenWidth(context))
            ..colorConfirmButton(actionButtonColor ?? AppColor.blue700)
            ..colorCancelButton(cancelButtonColor ?? AppColor.colorF3F6F9)
            ..styleTitle(titleStyle)
            ..styleContent(messageStyle)
            ..styleTextCancelButton(cancelStyle ?? const TextStyle(
              fontSize: 17,
              height: 24 / 17,
              fontWeight: FontWeight.w500,
              color: AppColor.steelGray600,
            ))
            ..styleTextConfirmButton(actionStyle ?? const TextStyle(
              fontSize: 17,
              height: 24 / 17,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ))
            ..onConfirmButtonAction(actionName, () {
              if (autoPerformPopBack) {
                popBack();
              }
              onConfirmAction?.call();
            })
            ..onCancelButtonAction(
                hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
                    () {
                  if (autoPerformPopBack) {
                    popBack();
                  }
                  onCancelAction?.call();
                }
            )
            ..onCloseButtonAction(onCloseButtonAction ?? () => popBack())
          ).build()
        );
        if (showAsBottomSheet) {
          return await Get.bottomSheet(
            usePopScope && PlatformInfo.isMobile
              ? PopScope(onPopInvokedWithResult: onPopInvoked, canPop: false, child: childWidget)
              : childWidget,
            isScrollControlled: true,
            barrierColor: AppColor.colorDefaultCupertinoActionSheet,
            backgroundColor: Colors.transparent,
            isDismissible: outsideDismissible,
            enableDrag: true,
            ignoreSafeArea: false,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
          );
        } else {
          return (ConfirmationDialogActionSheetBuilder(context, listTextSpan: listTextSpan)
            ..messageText(message)
            ..styleConfirmButton(const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black))
            ..styleMessage(messageStyle)
            ..styleCancelButton(cancelStyle)
            ..onCancelAction(
                cancelTitle ?? AppLocalizations.of(context).cancel,
                () {
                  if (autoPerformPopBack) {
                    popBack();
                  }
                  onCancelAction?.call();
                }
            )
            ..onConfirmAction(actionName, () {
                if (autoPerformPopBack) {
                  popBack();
                }
                onConfirmAction?.call();
            })).show();
        }
      } else {
        final childWidget = PointerInterceptor(
          child: (ConfirmDialogBuilder(
              imagePaths,
              listTextSpan: listTextSpan,
              titleActionButtonMaxLines: titleActionButtonMaxLines,
              isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
              useIconAsBasicLogo: useIconAsBasicLogo,
            )
            ..key(key)
            ..title(title ?? '')
            ..content(message)
            ..addIcon(icon)
            ..colorConfirmButton(actionButtonColor ?? AppColor.blue700)
            ..colorCancelButton(cancelButtonColor ?? AppColor.colorF3F6F9)
            ..styleTitle(titleStyle)
            ..styleContent(messageStyle)
            ..styleTextCancelButton(cancelStyle ?? const TextStyle(
              fontSize: 17,
              height: 24 / 17,
              fontWeight: FontWeight.w500,
              color: AppColor.steelGray600,
            ))
            ..styleTextConfirmButton(actionStyle ?? const TextStyle(
              fontSize: 17,
              height: 24 / 17,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ))
            ..onConfirmButtonAction(actionName, () {
              if (autoPerformPopBack) {
                popBack();
              }
              onConfirmAction?.call();
            })
            ..onCancelButtonAction(
                hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
                    () {
                  if (autoPerformPopBack) {
                    popBack();
                  }
                  onCancelAction?.call();
                }
            )
            ..onCloseButtonAction(onCloseButtonAction ?? () => popBack())
          ).build()
        );
        return await Get.dialog(
          usePopScope && PlatformInfo.isMobile
            ? PopScope(onPopInvokedWithResult: onPopInvoked, canPop: false, child: childWidget)
            : childWidget,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          barrierDismissible: outsideDismissible
        );
      }
    }
  }
}