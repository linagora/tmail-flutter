
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/platform_info.dart';
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
        child: ConfirmationDialogBuilder(
          key: key,
          imagePath: imagePaths,
          listTextSpan: listTextSpan,
          titleActionButtonMaxLines: titleActionButtonMaxLines,
          isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
          useIconAsBasicLogo: useIconAsBasicLogo,
          title: title ?? '',
          textContent: message,
          confirmText: actionName,
          cancelText: hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
          iconWidget: icon,
          colorCancelButton: cancelButtonColor,
          colorConfirmButton: actionButtonColor,
          styleTextCancelButton: cancelStyle,
          styleTextConfirmButton: actionStyle,
          styleTitle: titleStyle,
          styleContent: messageStyle,
          paddingButton: paddingButton,
          marginIcon: marginIcon,
          onConfirmButtonAction: () {
            if (autoPerformPopBack) {
              popBack();
            }
            onConfirmAction?.call();
          },
          onCancelButtonAction: () {
            if (autoPerformPopBack) {
              popBack();
            }
            onCancelAction?.call();
          },
          onCloseButtonAction: onCloseButtonAction,
        ),
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
          child: ConfirmationDialogBuilder(
            key: key,
            imagePath: imagePaths,
            showAsBottomSheet: true,
            listTextSpan: listTextSpan,
            maxWidth: responsiveUtils.getSizeScreenShortestSide(context) - 16,
            titleActionButtonMaxLines: titleActionButtonMaxLines,
            isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
            textContent: message,
            title: title ?? '',
            iconWidget: icon,
            widthDialog: responsiveUtils.getSizeScreenWidth(context),
            colorConfirmButton: actionButtonColor,
            colorCancelButton: cancelButtonColor,
            styleContent: messageStyle,
            styleTitle: titleStyle,
            styleTextCancelButton: cancelStyle,
            styleTextConfirmButton: actionStyle,
            confirmText: actionName,
            cancelText: hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
            useIconAsBasicLogo: useIconAsBasicLogo,
            onConfirmButtonAction: () {
              if (autoPerformPopBack) {
                popBack();
              }
              onConfirmAction?.call();
            },
            onCancelButtonAction: () {
              if (autoPerformPopBack) {
                popBack();
              }
              onCancelAction?.call();
            },
            onCloseButtonAction: onCloseButtonAction ?? popBack
          ),
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
            ..styleConfirmButton(actionStyle)
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
          child: ConfirmationDialogBuilder(
            key: key,
            imagePath: imagePaths,
            listTextSpan: listTextSpan,
            titleActionButtonMaxLines: titleActionButtonMaxLines,
            isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
            useIconAsBasicLogo: useIconAsBasicLogo,
            title: title ?? '',
            textContent: message,
            iconWidget: icon,
            colorConfirmButton: actionButtonColor,
            colorCancelButton: cancelButtonColor,
            styleContent: messageStyle,
            styleTitle: titleStyle,
            styleTextCancelButton: cancelStyle,
            styleTextConfirmButton: actionStyle,
            confirmText: actionName,
            cancelText: hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
            onConfirmButtonAction: () {
              if (autoPerformPopBack) {
                popBack();
              }
              onConfirmAction?.call();
            },
            onCancelButtonAction: () {
              if (autoPerformPopBack) {
                popBack();
              } else {
                onCancelAction?.call();
              }
            },
            onCloseButtonAction: onCloseButtonAction ?? popBack,
          ),
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