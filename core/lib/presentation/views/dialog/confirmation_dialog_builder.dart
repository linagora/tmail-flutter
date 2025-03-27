import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnConfirmButtonAction = void Function();
typedef OnCancelButtonAction = void Function();
typedef OnCloseButtonAction = void Function();

class ConfirmationDialogBuilder extends StatelessWidget {
  final ImagePaths imagePath;
  final String title;
  final String textContent;
  final String confirmText;
  final String cancelText;
  final Widget? iconWidget;
  final Widget? additionalWidgetContent;
  final Color? cancelBackgroundButtonColor;
  final Color? confirmBackgroundButtonColor;
  final Color? cancelLabelButtonColor;
  final Color? confirmLabelButtonColor;
  final TextStyle? styleTextCancelButton;
  final TextStyle? styleTextConfirmButton;
  final TextStyle? styleTitle;
  final TextStyle? styleContent;
  final double? radiusButton;
  final EdgeInsetsGeometry? paddingTitle;
  final EdgeInsetsGeometry? paddingContent;
  final EdgeInsetsGeometry? paddingButton;
  final EdgeInsetsGeometry? marginButton;
  final EdgeInsets? outsideDialogPadding;
  final EdgeInsetsGeometry? marginIcon;
  final EdgeInsetsGeometry? margin;
  final double? widthDialog;
  final double maxWidth;
  final Alignment? alignment;
  final Color? backgroundColor;
  final bool showAsBottomSheet;
  final List<TextSpan>? listTextSpan;
  final int? titleActionButtonMaxLines;
  final bool isArrangeActionButtonsVertical;
  final bool useIconAsBasicLogo;
  final OnConfirmButtonAction? onConfirmButtonAction;
  final OnCancelButtonAction? onCancelButtonAction;
  final OnCloseButtonAction? onCloseButtonAction;

  const ConfirmationDialogBuilder({
    super.key,
    required this.imagePath,
    this.title = '',
    this.textContent = '',
    this.confirmText = '',
    this.cancelText = '',
    this.iconWidget,
    this.additionalWidgetContent,
    this.cancelBackgroundButtonColor,
    this.confirmBackgroundButtonColor,
    this.cancelLabelButtonColor,
    this.confirmLabelButtonColor,
    this.styleTextCancelButton,
    this.styleTextConfirmButton,
    this.styleTitle,
    this.styleContent,
    this.radiusButton,
    this.paddingTitle,
    this.paddingContent,
    this.paddingButton,
    this.marginButton,
    this.outsideDialogPadding,
    this.marginIcon,
    this.margin,
    this.widthDialog,
    this.maxWidth = double.infinity,
    this.alignment,
    this.backgroundColor,
    this.showAsBottomSheet = false,
    this.listTextSpan,
    this.titleActionButtonMaxLines,
    this.isArrangeActionButtonsVertical = false,
    this.useIconAsBasicLogo = true,
    this.onConfirmButtonAction,
    this.onCancelButtonAction,
    this.onCloseButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return showAsBottomSheet
        ? _BodyContent(
            imagePath: imagePath,
            title: title,
            textContent: textContent,
            confirmText: confirmText,
            cancelText: cancelText,
            iconWidget: iconWidget,
            additionalWidgetContent: additionalWidgetContent,
            cancelBackgroundButtonColor: cancelBackgroundButtonColor,
            confirmBackgroundButtonColor: confirmBackgroundButtonColor,
            cancelLabelButtonColor: cancelLabelButtonColor,
            confirmLabelButtonColor: confirmLabelButtonColor,
            styleTextCancelButton: styleTextCancelButton,
            styleTextConfirmButton: styleTextConfirmButton,
            styleTitle: styleTitle,
            styleContent: styleContent,
            radiusButton: radiusButton,
            paddingTitle: paddingTitle,
            paddingContent: paddingContent,
            paddingButton: paddingButton,
            marginButton: marginButton,
            marginIcon: marginIcon,
            margin: margin,
            widthDialog: widthDialog,
            maxWidth: maxWidth,
            listTextSpan: listTextSpan,
            titleActionButtonMaxLines: titleActionButtonMaxLines,
            isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
            useIconAsBasicLogo: useIconAsBasicLogo,
            onConfirmButtonAction: onConfirmButtonAction,
            onCancelButtonAction: onCancelButtonAction,
            onCloseButtonAction: onCloseButtonAction,
          )
        : Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18))),
            insetPadding: outsideDialogPadding,
            alignment: alignment ?? Alignment.center,
            backgroundColor: backgroundColor,
            child: _BodyContent(
              imagePath: imagePath,
              title: title,
              textContent: textContent,
              confirmText: confirmText,
              cancelText: cancelText,
              iconWidget: iconWidget,
              additionalWidgetContent: additionalWidgetContent,
              cancelBackgroundButtonColor: cancelBackgroundButtonColor,
              confirmBackgroundButtonColor: confirmBackgroundButtonColor,
              cancelLabelButtonColor: cancelLabelButtonColor,
              confirmLabelButtonColor: confirmLabelButtonColor,
              styleTextCancelButton: styleTextCancelButton,
              styleTextConfirmButton: styleTextConfirmButton,
              styleTitle: styleTitle,
              styleContent: styleContent,
              radiusButton: radiusButton,
              paddingTitle: paddingTitle,
              paddingContent: paddingContent,
              paddingButton: paddingButton,
              marginButton: marginButton,
              marginIcon: marginIcon,
              margin: margin,
              widthDialog: widthDialog,
              maxWidth: maxWidth,
              listTextSpan: listTextSpan,
              titleActionButtonMaxLines: titleActionButtonMaxLines,
              isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
              useIconAsBasicLogo: useIconAsBasicLogo,
              onConfirmButtonAction: onConfirmButtonAction,
              onCancelButtonAction: onCancelButtonAction,
              onCloseButtonAction: onCloseButtonAction,
            ),
          );
  }
}

class _BodyContent extends StatelessWidget {
  final ImagePaths imagePath;
  final String title;
  final String textContent;
  final String confirmText;
  final String cancelText;
  final Widget? iconWidget;
  final Widget? additionalWidgetContent;
  final Color? cancelBackgroundButtonColor;
  final Color? confirmBackgroundButtonColor;
  final Color? cancelLabelButtonColor;
  final Color? confirmLabelButtonColor;
  final TextStyle? styleTextCancelButton;
  final TextStyle? styleTextConfirmButton;
  final TextStyle? styleTitle;
  final TextStyle? styleContent;
  final double? radiusButton;
  final EdgeInsetsGeometry? paddingTitle;
  final EdgeInsetsGeometry? paddingContent;
  final EdgeInsetsGeometry? paddingButton;
  final EdgeInsetsGeometry? marginButton;
  final EdgeInsetsGeometry? marginIcon;
  final EdgeInsetsGeometry? margin;
  final double? widthDialog;
  final double maxWidth;
  final List<TextSpan>? listTextSpan;
  final int? titleActionButtonMaxLines;
  final bool isArrangeActionButtonsVertical;
  final bool useIconAsBasicLogo;
  final OnConfirmButtonAction? onConfirmButtonAction;
  final OnCancelButtonAction? onCancelButtonAction;
  final OnCloseButtonAction? onCloseButtonAction;

  const _BodyContent({
    required this.imagePath,
    required this.title,
    required this.textContent,
    required this.confirmText,
    required this.cancelText,
    this.iconWidget,
    this.additionalWidgetContent,
    this.cancelBackgroundButtonColor,
    this.confirmBackgroundButtonColor,
    this.cancelLabelButtonColor,
    this.confirmLabelButtonColor,
    this.styleTextCancelButton,
    this.styleTextConfirmButton,
    this.styleTitle,
    this.styleContent,
    this.radiusButton,
    this.paddingTitle,
    this.paddingContent,
    this.paddingButton,
    this.marginButton,
    this.marginIcon,
    this.margin,
    this.widthDialog,
    required this.maxWidth,
    this.listTextSpan,
    this.titleActionButtonMaxLines,
    required this.isArrangeActionButtonsVertical,
    required this.useIconAsBasicLogo,
    this.onConfirmButtonAction,
    this.onCancelButtonAction,
    this.onCloseButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthDialog ?? 400,
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      margin: margin,
      padding: const EdgeInsetsDirectional.only(
        top: 11,
        end: 11,
        start: 16,
        bottom: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCloseButton(),
          _buildIcon(),
          _buildTitle(context),
          _buildContent(context),
          _buildAdditionalContent(),
          _buildActionButtons(context),
        ].where((widget) => widget != const SizedBox.shrink()).toList(),
      ),
    );
  }

  Widget _buildCloseButton() {
    return onCloseButtonAction != null
        ? Align(
            alignment: AlignmentDirectional.topEnd,
            child: TMailButtonWidget.fromIcon(
              icon: imagePath.icCloseDialog,
              iconSize: 29,
              iconColor: AppColor.steelGrayA540,
              padding: const EdgeInsets.all(5),
              backgroundColor: Colors.transparent,
              onTapActionCallback: onCloseButtonAction,
            ),
          )
        : const SizedBox(height: 24);
  }

  Widget _buildIcon() {
    if (useIconAsBasicLogo) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SvgPicture.asset(
          imagePath.icTMailLogo,
          fit: BoxFit.fill,
          width: 50,
          height: 50,
        ),
      );
    } else if (iconWidget != null) {
      return Container(
        margin: marginIcon ?? EdgeInsets.zero,
        alignment: Alignment.center,
        child: iconWidget,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTitle(BuildContext context) {
    return title.trim().isNotEmpty
        ? Padding(
            padding: paddingTitle ??
                const EdgeInsetsDirectional.only(top: 16, end: 5),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: styleTitle ??
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColor.m3SurfaceBackground,
                        ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context) {
    if (textContent.trim().isNotEmpty) {
      return Padding(
        padding:
            paddingContent ?? const EdgeInsetsDirectional.only(top: 16, end: 5),
        child: Center(
          child: Text(
            textContent,
            textAlign: TextAlign.center,
            style: styleContent ??
                Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColor.steelGrayA540,
                    ),
          ),
        ),
      );
    } else if (listTextSpan != null) {
      return Padding(
        padding:
            paddingContent ?? const EdgeInsetsDirectional.only(top: 16, end: 5),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: styleContent ??
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.steelGrayA540,
                      ),
              children: listTextSpan,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAdditionalContent() {
    return additionalWidgetContent != null
        ? Padding(
            padding: const EdgeInsetsDirectional.only(top: 16, end: 5),
            child: additionalWidgetContent!,
          )
        : const SizedBox.shrink();
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isArrangeActionButtonsVertical) {
      return Padding(
        padding: marginButton ??
            const EdgeInsetsDirectional.only(start: 15, end: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cancelText.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 16),
                child: _buildButton(
                  context,
                  cancelText,
                  onCancelButtonAction,
                  cancelBackgroundButtonColor,
                  cancelLabelButtonColor,
                  styleTextCancelButton,
                ),
              ),
            if (confirmText.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 16),
                child: _buildButton(
                  context,
                  confirmText,
                  onConfirmButtonAction,
                  confirmBackgroundButtonColor,
                  confirmLabelButtonColor,
                  styleTextConfirmButton,
                ),
              ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: marginButton ??
            const EdgeInsetsDirectional.only(top: 16, start: 15, end: 20),
        child: Row(
          children: [
            if (cancelText.isNotEmpty)
              Expanded(
                child: _buildButton(
                  context,
                  cancelText,
                  onCancelButtonAction,
                  cancelBackgroundButtonColor,
                  cancelLabelButtonColor,
                  styleTextCancelButton,
                ),
              ),
            if (confirmText.isNotEmpty && cancelText.isNotEmpty)
              const SizedBox(width: 16),
            if (confirmText.isNotEmpty)
              Expanded(
                child: _buildButton(
                  context,
                  confirmText,
                  onConfirmButtonAction,
                  confirmBackgroundButtonColor,
                  confirmLabelButtonColor,
                  styleTextConfirmButton,
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    VoidCallback? onTapAction,
    Color? bgColor,
    Color? textColor,
    TextStyle? textStyle,
  ) {
    return ConfirmDialogButton(
      label: label,
      backgroundColor: bgColor ??
          (onTapAction == onConfirmButtonAction
              ? AppColor.blue700
              : AppColor.grayBackgroundColor),
      borderRadius: radiusButton,
      textStyle: textStyle,
      padding: paddingButton,
      textColor: textColor ??
        (onTapAction == onConfirmButtonAction
          ? Colors.white
          : AppColor.steelGray600),
      maxLines: titleActionButtonMaxLines,
      onTapAction: onTapAction,
    );
  }
}
