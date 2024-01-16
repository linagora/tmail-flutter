
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin MessageDialogActionMixin {

  Future<dynamic> showConfirmDialogAction({
    required BuildContext context,
    String? message,
    String? actionName,
    Function? onConfirmAction,
    Function? onCancelAction,
    String? title,
    String? cancelTitle,
    bool hasCancelButton = true,
    bool showAsBottomSheet = false,
    bool alignCenter = false,
    List<TextSpan>? listTextSpan,
    Widget? icon,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? actionStyle,
    TextStyle? cancelStyle,
    Color? actionButtonColor,
    Color? cancelButtonColor,
    EdgeInsetsGeometry? titlePadding,
  }) async {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final imagePaths = Get.find<ImagePaths>();

    if (alignCenter) {
      return await Get.dialog(
        PointerInterceptor(
          child: (ConfirmDialogBuilder(imagePaths, listTextSpan: listTextSpan, heightButton: 44)
            ..key(const Key('confirm_dialog_action'))
            ..title(title ?? '')
            ..content(message ?? '')
            ..addIcon(icon)
            ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
            ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
            ..marginIcon(icon != null ? const EdgeInsets.only(top: 24) : null)
            ..paddingTitle(icon != null ? const EdgeInsets.only(top: 24) : titlePadding ?? EdgeInsets.zero)
            ..radiusButton(12)
            ..paddingContent(const EdgeInsetsDirectional.only(start: 24, end: 24, bottom: 24, top: 12))
            ..paddingButton(hasCancelButton ? null : const EdgeInsetsDirectional.only(bottom: 24, start: 24, end: 24))
            ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
            ..styleContent(messageStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
            ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
            ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
            ..onConfirmButtonAction(actionName ?? AppLocalizations.of(context).yes, () {
                popBack();
                onConfirmAction?.call();
            })
            ..onCancelButtonAction(
                hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
                () {
                  popBack();
                  onCancelAction?.call();
                }
            )
          ).build()
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    } else {
      if (responsiveUtils.isMobile(context)) {
        if (showAsBottomSheet) {
          return await Get.bottomSheet(
            PointerInterceptor(
              child: (ConfirmDialogBuilder(
                imagePaths,
                showAsBottomSheet: true,
                listTextSpan: listTextSpan,
                maxWith: responsiveUtils.getSizeScreenShortestSide(context) - 16
              )
                ..key(const Key('confirm_dialog_action'))
                ..title(title ?? '')
                ..content(message ?? '')
                ..addIcon(icon)
                ..margin(const EdgeInsets.only(bottom: 42))
                ..widthDialog(responsiveUtils.getSizeScreenWidth(context))
                ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
                ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
                ..paddingTitle(icon != null ? const EdgeInsets.only(top: 24) : titlePadding ?? EdgeInsets.zero)
                ..marginIcon(EdgeInsets.zero)
                ..paddingContent(const EdgeInsetsDirectional.only(start: 44, end: 44, bottom: 24, top: 12))
                ..paddingButton(hasCancelButton ? null : const EdgeInsetsDirectional.only(bottom: 16, start: 44, end: 44))
                ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
                ..styleContent(messageStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
                ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
                ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
                ..onConfirmButtonAction(actionName ?? AppLocalizations.of(context).yes, () {
                    popBack();
                    onConfirmAction?.call();
                })
                ..onCancelButtonAction(
                    hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
                    () {
                      popBack();
                      onCancelAction?.call();
                    }
                )
                ..onCloseButtonAction(() => popBack()))
              .build()
            ),
            isScrollControlled: true,
            barrierColor: AppColor.colorDefaultCupertinoActionSheet,
            backgroundColor: Colors.transparent,
            enableDrag: true,
            ignoreSafeArea: false,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
          );
        } else {
          return (ConfirmationDialogActionSheetBuilder(context, listTextSpan: listTextSpan)
            ..messageText(message ?? '')
            ..styleConfirmButton(const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black))
            ..styleMessage(messageStyle)
            ..styleCancelButton(cancelStyle)
            ..onCancelAction(
                cancelTitle ?? AppLocalizations.of(context).cancel,
                () {
                  popBack();
                  onCancelAction?.call();
                }
            )
            ..onConfirmAction(actionName ?? AppLocalizations.of(context).yes, () {
                popBack();
                onConfirmAction?.call();
            })).show();
        }
      } else {
        return await Get.dialog(
          PointerInterceptor(
            child: (ConfirmDialogBuilder(imagePaths, listTextSpan: listTextSpan)
              ..key(const Key('confirm_dialog_action'))
              ..title(title ?? '')
              ..content(message ?? '')
              ..addIcon(icon)
              ..colorConfirmButton(actionButtonColor ?? AppColor.colorTextButton)
              ..colorCancelButton(cancelButtonColor ?? AppColor.colorCancelButton)
              ..marginIcon(icon != null ? const EdgeInsets.only(top: 24) : null)
              ..paddingTitle(icon != null ? const EdgeInsets.only(top: 24) : titlePadding ?? EdgeInsets.zero)
              ..marginIcon(EdgeInsets.zero)
              ..paddingContent(const EdgeInsetsDirectional.only(start: 44, end: 44, bottom: 24, top: 12))
              ..paddingButton(hasCancelButton ? null : const EdgeInsets.only(bottom: 16, left: 44, right: 44))
              ..styleTitle(titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
              ..styleContent(messageStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.colorContentEmail))
              ..styleTextCancelButton(cancelStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))
              ..styleTextConfirmButton(actionStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white))
              ..onConfirmButtonAction(actionName ?? AppLocalizations.of(context).yes, () {
                popBack();
                onConfirmAction?.call();
              })
              ..onCancelButtonAction(
                  hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
                  () {
                    popBack();
                    onCancelAction?.call();
                  }
              )
              ..onCloseButtonAction(() => popBack()))
            .build()
          ),
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        );
      }
    }
  }
}