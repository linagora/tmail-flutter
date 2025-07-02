import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
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
  final EdgeInsets? outsideDialogPadding;
  final EdgeInsetsGeometry? margin;
  final double maxWidth;
  final Alignment? alignment;
  final bool showAsBottomSheet;
  final List<TextSpan>? listTextSpan;
  final bool isArrangeActionButtonsVertical;
  final bool useIconAsBasicLogo;
  final bool isScrollContentEnabled;
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
    this.outsideDialogPadding,
    this.margin,
    this.maxWidth = double.infinity,
    this.alignment,
    this.showAsBottomSheet = false,
    this.listTextSpan,
    this.isArrangeActionButtonsVertical = false,
    this.useIconAsBasicLogo = false,
    this.isScrollContentEnabled = false,
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
            margin: margin,
            maxWidth: maxWidth,
            listTextSpan: listTextSpan,
            isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
            useIconAsBasicLogo: useIconAsBasicLogo,
            isScrollContentEnabled: isScrollContentEnabled,
            onConfirmButtonAction: onConfirmButtonAction,
            onCancelButtonAction: onCancelButtonAction,
            onCloseButtonAction: onCloseButtonAction,
          )
        : Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            insetPadding: outsideDialogPadding,
            alignment: alignment ?? Alignment.center,
            backgroundColor: Colors.white,
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
              margin: margin,
              maxWidth: maxWidth,
              listTextSpan: listTextSpan,
              isArrangeActionButtonsVertical: isArrangeActionButtonsVertical,
              useIconAsBasicLogo: useIconAsBasicLogo,
              isScrollContentEnabled: isScrollContentEnabled,
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
  final EdgeInsetsGeometry? margin;
  final double maxWidth;
  final List<TextSpan>? listTextSpan;
  final bool isArrangeActionButtonsVertical;
  final bool useIconAsBasicLogo;
  final bool isScrollContentEnabled;
  final OnConfirmButtonAction? onConfirmButtonAction;
  final OnCancelButtonAction? onCancelButtonAction;
  final OnCloseButtonAction? onCloseButtonAction;

  const _BodyContent({
    required this.imagePath,
    required this.title,
    required this.textContent,
    required this.confirmText,
    required this.cancelText,
    required this.maxWidth,
    required this.isArrangeActionButtonsVertical,
    required this.useIconAsBasicLogo,
    this.isScrollContentEnabled = false,
    this.iconWidget,
    this.additionalWidgetContent,
    this.cancelBackgroundButtonColor,
    this.confirmBackgroundButtonColor,
    this.cancelLabelButtonColor,
    this.confirmLabelButtonColor,
    this.margin,
    this.listTextSpan,
    this.onConfirmButtonAction,
    this.onCancelButtonAction,
    this.onCloseButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 421,
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: margin,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 32,
              end: 32,
              top: 24,
              bottom: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(),
                _buildTitle(context),
                _buildContent(context),
                _buildAdditionalContent(),
                _buildActionButtons(context),
              ].where((widget) => widget != const SizedBox.shrink()).toList(),
            ),
          ),
          if (_showCloseButton()) _buildCloseButton(),
        ],
      ),
    );

    if (isScrollContentEnabled) {
      return SingleChildScrollView(child: child);
    } else {
      return child;
    }
  }

  bool _showCloseButton() => onCloseButtonAction != null;

  Widget _buildCloseButton() {
    return PositionedDirectional(
      top: 4,
      end: 4,
      child: TMailButtonWidget.fromIcon(
        icon: imagePath.icCloseDialog,
        iconSize: 24,
        iconColor: AppColor.m3Tertiary,
        padding: const EdgeInsets.all(10),
        borderRadius: 24,
        backgroundColor: Colors.transparent,
        onTapActionCallback: onCloseButtonAction,
      ),
    );
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
      return Center(child: iconWidget);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTitle(BuildContext context) {
    return title.trim().isNotEmpty
        ? Center(
            child: Text(
              title,
              style: ThemeUtils.textStyleM3HeadlineSmall.copyWith(
                color: AppColor.textPrimary,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context) {
    if (textContent.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 32),
        child: Text(
          textContent,
          style: ThemeUtils.textStyleM3BodyMedium1,
        ),
      );
    } else if (listTextSpan != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 32),
        child: RichText(
          text: TextSpan(
            style: ThemeUtils.textStyleM3BodyMedium1,
            children: listTextSpan,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAdditionalContent() {
    return additionalWidgetContent != null
        ? Padding(
            padding: const EdgeInsetsDirectional.only(top: 16),
            child: additionalWidgetContent!,
          )
        : const SizedBox.shrink();
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isArrangeActionButtonsVertical ||
        cancelText.isEmpty ||
        confirmText.isEmpty
    ) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cancelText.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ConfirmDialogButton(
                  label: cancelText,
                  backgroundColor: cancelBackgroundButtonColor,
                  textColor: cancelLabelButtonColor,
                  onTapAction: onCancelButtonAction,
                ),
              ),
            if (confirmText.isNotEmpty && cancelText.isNotEmpty)
              const SizedBox(height: 8),
            if (confirmText.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ConfirmDialogButton(
                  label: confirmText,
                  backgroundColor: confirmBackgroundButtonColor
                      ?? AppColor.primaryMain,
                  textColor: confirmLabelButtonColor ?? Colors.white,
                  onTapAction: onConfirmButtonAction,
                ),
              ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 44,
          start: 12,
          end: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(minWidth: 67),
                height: 48,
                child: ConfirmDialogButton(
                  label: cancelText,
                  backgroundColor: cancelBackgroundButtonColor,
                  textColor: cancelLabelButtonColor,
                  onTapAction: onCancelButtonAction,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(minWidth: 135),
                height: 48,
                child: ConfirmDialogButton(
                  label: confirmText,
                  backgroundColor: confirmBackgroundButtonColor
                      ?? AppColor.primaryMain,
                  textColor: confirmLabelButtonColor ?? Colors.white,
                  onTapAction: onConfirmButtonAction,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
