
import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TMailButtonWidget extends StatelessWidget {

  final OnTapActionCallback? onTapActionCallback;
  final OnTapActionAtPositionCallback? onTapActionAtPositionCallback;
  final OnLongPressActionCallback? onLongPressActionCallback;

  final double borderRadius;
  final double? width;
  final double maxWidth;
  final double maxHeight;
  final double minWidth;
  final String? tooltipMessage;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String text;
  final String? icon;
  final bool verticalDirection;
  final double? iconSize;
  final double iconSpace;
  final Color? iconColor;
  final TextStyle? textStyle;
  final String? trailingIcon;
  final double? trailingIconSize;
  final Color? trailingIconColor;
  final List<BoxShadow>? boxShadow;
  final TextAlign? textAlign;
  final bool flexibleText;
  final BoxBorder? border;
  final TextDirection iconAlignment;
  final int? maxLines;
  final MainAxisSize mainAxisSize;
  final bool isLoading;
  final Color? hoverColor;
  final TextOverflow? textOverflow;
  final bool expandedText;

  const TMailButtonWidget({
    super.key,
    required this.text,
    this.onTapActionCallback,
    this.onTapActionAtPositionCallback,
    this.onLongPressActionCallback,
    this.borderRadius = 20,
    this.width,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.minWidth = 0,
    this.tooltipMessage,
    this.backgroundColor,
    this.padding,
    this.verticalDirection = false,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.textStyle,
    this.iconSpace = 8,
    this.trailingIcon,
    this.trailingIconSize,
    this.trailingIconColor,
    this.boxShadow,
    this.margin,
    this.textAlign,
    this.flexibleText = false,
    this.border,
    this.iconAlignment = TextDirection.ltr,
    this.maxLines,
    this.mainAxisSize = MainAxisSize.max,
    this.isLoading = false,
    this.hoverColor,
    this.textOverflow,
    this.expandedText = false,
  });

  factory TMailButtonWidget.fromIcon({
    required String icon,
    final Key? key,
    OnTapActionCallback? onTapActionCallback,
    OnTapActionAtPositionCallback? onTapActionAtPositionCallback,
    OnLongPressActionCallback? onLongPressActionCallback,
    double borderRadius = 20,
    double? width,
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    double minWidth = 0,
    String? tooltipMessage,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double? iconSize,
    Color? iconColor,
    double iconSpace = 8,
    String? trailingIcon,
    double? trailingIconSize,
    Color? trailingIconColor,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? margin,
    Color? hoverColor,
  }) {
    return TMailButtonWidget(
      key: key,
      text: '',
      onTapActionCallback: onTapActionCallback,
      onTapActionAtPositionCallback: onTapActionAtPositionCallback,
      onLongPressActionCallback: onLongPressActionCallback,
      borderRadius: borderRadius,
      width: width,
      maxWidth : maxWidth,
      maxHeight: maxHeight,
      minWidth: minWidth,
      tooltipMessage: tooltipMessage,
      backgroundColor: backgroundColor,
      padding: padding,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      iconSpace: iconSpace,
      trailingIcon: trailingIcon,
      trailingIconSize: trailingIconSize,
      trailingIconColor: trailingIconColor,
      boxShadow: boxShadow,
      margin: margin,
      hoverColor: hoverColor,
    );
  }

  factory TMailButtonWidget.fromText({
    required String text,
    final Key? key,
    OnTapActionCallback? onTapActionCallback,
    OnTapActionAtPositionCallback? onTapActionAtPositionCallback,
    OnLongPressActionCallback? onLongPressActionCallback,
    double borderRadius = 20,
    double? width,
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    double minWidth = 0,
    String? tooltipMessage,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? margin,
    TextAlign? textAlign,
    bool flexibleText = false,
    BoxBorder? border,
    int? maxLines,
    Color? hoverColor,
    TextOverflow? textOverflow,
    bool expandedText = false,
  }) {
    return TMailButtonWidget(
      key: key,
      text: text,
      onTapActionCallback: onTapActionCallback,
      onTapActionAtPositionCallback: onTapActionAtPositionCallback,
      onLongPressActionCallback: onLongPressActionCallback,
      borderRadius: borderRadius,
      width: width,
      maxWidth : maxWidth,
      maxHeight: maxHeight,
      minWidth: minWidth,
      tooltipMessage: tooltipMessage,
      backgroundColor: backgroundColor,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      margin: margin,
      textAlign: textAlign,
      flexibleText: flexibleText,
      border: border,
      maxLines: maxLines,
      hoverColor: hoverColor,
      textOverflow: textOverflow,
      expandedText: expandedText,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget;

    if (icon != null && text.isNotEmpty) {
      if (verticalDirection) {
        childWidget = Column(
          mainAxisSize: mainAxisSize,
          children: [
            SvgPicture.asset(
              icon!,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.fill,
              colorFilter: iconColor?.asFilter()
            ),
            SizedBox(height: iconSpace),
            Text(
              text,
              textAlign: textAlign,
              style: textStyle ?? const TextStyle(
                fontSize: 12,
                color: AppColor.colorTextButtonHeaderThread
              ),
              maxLines: maxLines,
              overflow: textOverflow ?? (maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null),
              softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
            ),
            if (trailingIcon != null)
              Padding(
                padding: EdgeInsetsDirectional.only(top: iconSpace),
                child: SvgPicture.asset(
                  trailingIcon!,
                  width: trailingIconSize,
                  height: trailingIconSize,
                  fit: BoxFit.fill,
                  colorFilter: trailingIconColor?.asFilter()
                ),
              ),
          ]
        );
      } else {
        if (iconAlignment == TextDirection.ltr) {
          childWidget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: mainAxisSize,
            children: [
              SvgPicture.asset(
                icon!,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.fill,
                colorFilter: iconColor?.asFilter()
              ),
              SizedBox(width: iconSpace),
              if (flexibleText)
                Flexible(
                  child: Text(
                    text,
                    textAlign: textAlign,
                    style: textStyle ?? const TextStyle(
                      fontSize: 12,
                      color: AppColor.colorTextButtonHeaderThread
                    ),
                    maxLines: maxLines,
                    overflow: maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null,
                    softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
                  ),
                )
              else if (expandedText)
                Expanded(
                  child: Text(
                    text,
                    textAlign: textAlign,
                    style: textStyle ?? const TextStyle(
                      fontSize: 12,
                      color: AppColor.colorTextButtonHeaderThread
                    ),
                    maxLines: maxLines,
                    overflow: textOverflow ?? (maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null),
                    softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
                  ),
                )
              else
                Text(
                  text,
                  textAlign: textAlign,
                  style: textStyle ?? const TextStyle(
                    fontSize: 12,
                    color: AppColor.colorTextButtonHeaderThread
                  ),
                  maxLines: maxLines,
                  overflow: textOverflow ?? (maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null),
                  softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
                ),
              if (trailingIcon != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: iconSpace),
                  child: SvgPicture.asset(
                    trailingIcon!,
                    width: trailingIconSize,
                    height: trailingIconSize,
                    fit: BoxFit.fill,
                    colorFilter: trailingIconColor?.asFilter()
                  ),
                ),
            ]
          );
        } else {
          childWidget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: mainAxisSize,
            children: [
              if (flexibleText)
                Flexible(
                  child: Text(
                    text,
                    textAlign: textAlign,
                    style: textStyle ?? const TextStyle(
                      fontSize: 12,
                      color: AppColor.colorTextButtonHeaderThread
                    ),
                    maxLines: maxLines,
                    overflow: maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null,
                    softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
                  ),
                )
              else if (expandedText)
                Expanded(
                  child: Text(
                    text,
                    textAlign: textAlign,
                    style: textStyle ?? const TextStyle(
                      fontSize: 12,
                      color: AppColor.colorTextButtonHeaderThread
                    ),
                    maxLines: maxLines,
                    overflow: textOverflow ?? (maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null),
                    softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
                  ),
                )
              else
                Text(
                  text,
                  textAlign: textAlign,
                  style: textStyle ?? const TextStyle(
                    fontSize: 12,
                    color: AppColor.colorTextButtonHeaderThread
                  ),
                  maxLines: maxLines,
                  overflow: textOverflow ?? (maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null),
                  softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
                ),
              SizedBox(width: iconSpace),
              if (!isLoading)
                SvgPicture.asset(
                  icon!,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.fill,
                  colorFilter: iconColor?.asFilter()
                )
              else 
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                ),
            ]
          );
        }
      }
    } else if (icon != null) {
      childWidget = SvgPicture.asset(
        icon!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.fill,
        colorFilter: iconColor?.asFilter()
      );
    } else {
      childWidget = Text(
        text,
        textAlign: textAlign,
        style: textStyle ?? const TextStyle(
          fontSize: 12,
          color: AppColor.colorTextButtonHeaderThread
        ),
        maxLines: maxLines,
        overflow: textOverflow ?? (maxLines == 1 ? CommonTextStyle.defaultTextOverFlow : null),
        softWrap: maxLines == 1 ? CommonTextStyle.defaultSoftWrap : null,
      );
    }

    return TMailContainerWidget(
      onTapActionCallback: onTapActionCallback,
      onTapActionAtPositionCallback: onTapActionAtPositionCallback,
      onLongPressActionCallback: onLongPressActionCallback,
      borderRadius: borderRadius,
      width: width,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      minWidth: minWidth,
      tooltipMessage: tooltipMessage,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      boxShadow: boxShadow,
      border: border,
      hoverColor: hoverColor,
      child: childWidget,
    );
  }
}