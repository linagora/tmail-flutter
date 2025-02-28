
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
        Function? onConfirmAction,
        Function? onCancelAction,
        OnCloseButtonAction? onCloseButtonAction,
        String? title,
        String? cancelTitle,
        bool hasCancelButton = true,
        bool showAsBottomSheet = false,
        bool alignCenter = false,
        bool outsideDismissible = false,
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
        EdgeInsetsGeometry? titlePadding,
      }
  ) async {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final imagePaths = Get.find<ImagePaths>();

    final paddingTitle = titlePadding ??
        (icon != null
            ? const EdgeInsetsDirectional.only(top: 24, start: 24, end: 24)
            : const EdgeInsetsDirectional.symmetric(horizontal: 24));

    if (alignCenter) {
      final childWidget = PointerInterceptor(
        child: (ConfirmDialogBuilder(
            imagePaths,
            listTextSpan: listTextSpan,
            titleActionButtonMaxLines: titleActionButtonMaxLines,
            isArrangeActionButtonsVertical: isArrangeActionButtonsVertical
          )
          ..key(const Key('confirm_dialog_action'))
          ..title(title ?? '')
          ..content(message)
          ..addIcon(icon)
          ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
          ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
          ..marginIcon(icon != null ? (marginIcon ?? const EdgeInsets.only(top: 24)) : null)
          ..paddingTitle(paddingTitle)
          ..radiusButton(12)
          ..paddingButton(paddingButton)
          ..paddingContent(const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12))
          ..marginButton(hasCancelButton ? null : const EdgeInsets.only(bottom: 24, left: 24, right: 24))
          ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
          ..styleContent(messageStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
          ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
          ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
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
              isArrangeActionButtonsVertical: isArrangeActionButtonsVertical
            )
            ..key(const Key('confirm_dialog_action'))
            ..title(title ?? '')
            ..content(message)
            ..addIcon(icon)
            ..paddingButton(paddingButton)
            ..margin(const EdgeInsets.only(bottom: 42))
            ..widthDialog(responsiveUtils.getSizeScreenWidth(context))
            ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
            ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
            ..paddingTitle(paddingTitle)
            ..marginIcon(EdgeInsets.zero)
            ..paddingContent(const EdgeInsets.only(left: 44, right: 44, bottom: 24, top: 12))
            ..marginButton(hasCancelButton ? null : const EdgeInsets.only(bottom: 16, left: 44, right: 44))
            ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
            ..styleContent(messageStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
            ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
            ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
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
              isArrangeActionButtonsVertical: isArrangeActionButtonsVertical
            )
            ..key(const Key('confirm_dialog_action'))
            ..title(title ?? '')
            ..content(message)
            ..addIcon(icon)
            ..paddingButton(paddingButton)
            ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
            ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
            ..marginIcon(icon != null ? const EdgeInsets.only(top: 24) : null)
            ..paddingTitle(paddingTitle)
            ..marginIcon(EdgeInsets.zero)
            ..paddingContent(const EdgeInsets.only(left: 44, right: 44, bottom: 24, top: 12))
            ..marginButton(hasCancelButton ? null : const EdgeInsets.only(bottom: 16, left: 44, right: 44))
            ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
            ..styleContent(messageStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
            ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
            ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
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