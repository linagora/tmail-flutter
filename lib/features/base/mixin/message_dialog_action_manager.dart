
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MessageDialogActionManager {
  static final _instance = MessageDialogActionManager._();

  factory MessageDialogActionManager() => _instance;

  MessageDialogActionManager._();

  final _isConfirmDialogOpened = RxBool(false);
  final _isInputDialogOpened = RxBool(false);
  bool get isDialogOpened => _isConfirmDialogOpened.value || _isInputDialogOpened.value;
  
  Future<void> showConfirmDialogAction(
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
        Widget? additionalWidgetContent,
        Color? actionButtonColor,
        Color? cancelButtonColor,
        Color? cancelLabelButtonColor,
        Color? confirmLabelButtonColor,
        PopInvokedWithResultCallback? onPopInvoked,
        bool isArrangeActionButtonsVertical = false,
        bool useIconAsBasicLogo = false,
        bool isScrollContentEnabled = false,
        EdgeInsetsGeometry? dialogMargin,
        EdgeInsets? outsideDialogPadding,
      }
  ) async {
    if (PlatformInfo.isWeb) {
      _isConfirmDialogOpened.value = true;
    }
    
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final imagePaths = Get.find<ImagePaths>();

    if (alignCenter) {
      final childWidget = ConfirmationDialogBuilder(
        key: key,
        imagePath: imagePaths,
        listTextSpan: listTextSpan,
        isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
        useIconAsBasicLogo: useIconAsBasicLogo,
        isScrollContentEnabled: isScrollContentEnabled,
        title: title ?? '',
        textContent: message,
        confirmText: actionName,
        cancelText: hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
        iconWidget: icon,
        outsideDialogPadding: outsideDialogPadding ??
            (responsiveUtils.isScreenWithShortestSide(context)
                ? const EdgeInsets.all(16)
                : null),
        additionalWidgetContent: additionalWidgetContent,
        cancelBackgroundButtonColor: cancelButtonColor,
        confirmBackgroundButtonColor: actionButtonColor,
        cancelLabelButtonColor: cancelLabelButtonColor,
        confirmLabelButtonColor: confirmLabelButtonColor,
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
      );
      await Get.dialog(
        usePopScope && PlatformInfo.isMobile
          ? PopScope(onPopInvokedWithResult: onPopInvoked, canPop: false, child: childWidget)
          : childWidget,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        barrierDismissible: outsideDismissible
      );
    } else {
      if (responsiveUtils.isMobile(context)) {
        final childWidget = ConfirmationDialogBuilder(
          key: key,
          imagePath: imagePaths,
          showAsBottomSheet: true,
          listTextSpan: listTextSpan,
          maxWidth: responsiveUtils.getSizeScreenShortestSide(context) - 16,
          isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
          textContent: message,
          title: title ?? '',
          iconWidget: icon,
          outsideDialogPadding: outsideDialogPadding ??
              (responsiveUtils.isScreenWithShortestSide(context)
                  ? const EdgeInsets.all(16)
                  : null),
          additionalWidgetContent: additionalWidgetContent,
          margin: dialogMargin,
          confirmBackgroundButtonColor: actionButtonColor,
          cancelBackgroundButtonColor: cancelButtonColor,
          cancelLabelButtonColor: cancelLabelButtonColor,
          confirmLabelButtonColor: confirmLabelButtonColor,
          confirmText: actionName,
          cancelText: hasCancelButton ? cancelTitle ?? AppLocalizations.of(context).cancel : '',
          useIconAsBasicLogo: useIconAsBasicLogo,
          isScrollContentEnabled: isScrollContentEnabled,
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
          onCloseButtonAction: onCloseButtonAction ?? popBack,
        );
        if (showAsBottomSheet) {
          await Get.bottomSheet(
            usePopScope && PlatformInfo.isMobile
              ? PopScope(onPopInvokedWithResult: onPopInvoked, canPop: false, child: childWidget)
              : childWidget,
            isScrollControlled: true,
            barrierColor: AppColor.colorDefaultCupertinoActionSheet,
            backgroundColor: Colors.transparent,
            isDismissible: outsideDismissible,
            enableDrag: true,
            ignoreSafeArea: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
          );
        } else {
          await (ConfirmationDialogActionSheetBuilder(context, listTextSpan: listTextSpan)
            ..messageText(message)
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
        final childWidget = ConfirmationDialogBuilder(
          key: key,
          imagePath: imagePaths,
          listTextSpan: listTextSpan,
          isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
          useIconAsBasicLogo: useIconAsBasicLogo,
          isScrollContentEnabled: isScrollContentEnabled,
          title: title ?? '',
          textContent: message,
          iconWidget: icon,
          additionalWidgetContent: additionalWidgetContent,
          confirmBackgroundButtonColor: actionButtonColor,
          cancelBackgroundButtonColor: cancelButtonColor,
          cancelLabelButtonColor: cancelLabelButtonColor,
          confirmLabelButtonColor: confirmLabelButtonColor,
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
            }
            onCancelAction?.call();
          },
          onCloseButtonAction: onCloseButtonAction ?? popBack,
          outsideDialogPadding: outsideDialogPadding,
        );
        await Get.dialog(
          usePopScope && PlatformInfo.isMobile
            ? PopScope(onPopInvokedWithResult: onPopInvoked, canPop: false, child: childWidget)
            : childWidget,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          barrierDismissible: outsideDismissible
        );
      }
    }
    _isConfirmDialogOpened.value = false;
  }

  Future<void> showInputDialogAction({
    required BuildContext context,
    required String title,
    required String value,
    required String positiveText,
    required String negativeText,
    required OnInputDialogPositiveButtonAction onPositiveButtonAction,
    Key? key,
    String? closeIcon,
    OnInputDialogNegativeButtonAction? onNegativeButtonAction,
    OnInputDialogInputErrorChangedAction? onInputErrorChanged,
    bool outsideDismissible = false,
  }) async {
    _isInputDialogOpened.value = true;
    
    await Get.dialog(
      EditTextDialogBuilder(
        key: key,
        title: AppLocalizations.of(context).renameFolder,
        value: value,
        positiveText: positiveText,
        negativeText: negativeText,
        closeIcon: closeIcon,
        onInputErrorChanged: onInputErrorChanged,
        onPositiveButtonAction: onPositiveButtonAction,
        onNegativeButtonAction: onNegativeButtonAction,
        onCloseButtonAction: closeIcon != null ? popBack : null,
      ),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      barrierDismissible: outsideDismissible,
    );
    _isInputDialogOpened.value = false;
    
  }
}