import 'package:core/presentation/views/image/image_loader_mixin.dart';
import 'package:flutter/material.dart';

/// A builder which builds a reusable slogan widget.
/// This contains the logo and the slogan text.
/// The elements are arranged in a column or row.

typedef OnTapCallback = void Function();

class SloganBuilder extends StatelessWidget with ImageLoaderMixin {

  final bool arrangedByHorizontal;
  final String? text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final String? logo;
  final double? sizeLogo;
  final OnTapCallback? onTapCallback;
  final EdgeInsetsGeometry? paddingText;
  final EdgeInsetsGeometry? padding;
  final bool enableOverflow;
  final Color? hoverColor;
  final double? hoverRadius;

  const SloganBuilder({
    super.key,
    this.arrangedByHorizontal = true,
    this.enableOverflow = false,
    this.text,
    this.textStyle,
    this.textAlign,
    this.logo,
    this.sizeLogo,
    this.onTapCallback,
    this.padding,
    this.paddingText,
    this.hoverColor,
    this.hoverRadius
  });

  @override
  Widget build(BuildContext context) {
    if (!arrangedByHorizontal) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTapCallback,
          hoverColor: hoverColor,
          borderRadius: BorderRadius.all(Radius.circular(hoverRadius ?? 8)),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Column(children: [
              if (logo != null)
                buildImage(
                  imagePath: logo!,
                  imageSize: sizeLogo,
                ),
              Padding(
                padding: paddingText ?? const EdgeInsetsDirectional.only(top: 16, start: 16, end: 16),
                child: Text(
                  text ?? '',
                  style: textStyle,
                  textAlign: textAlign,
                  overflow: enableOverflow ? TextOverflow.ellipsis : null,
                  maxLines: enableOverflow ? 1 : null,
                ),
              ),
            ]),
          ),
        ),
      );
    } else {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTapCallback,
          hoverColor: hoverColor,
          radius: hoverRadius ?? 8,
          borderRadius: BorderRadius.all(Radius.circular(hoverRadius ?? 8)),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Row(children: [
              if (logo != null)
                buildImage(
                  imagePath: logo!,
                  imageSize: sizeLogo,
                ),
              Padding(
                padding: paddingText ?? const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  text ?? '',
                  style: textStyle,
                  textAlign: textAlign,
                  overflow: enableOverflow ? TextOverflow.ellipsis : null,
                  maxLines: enableOverflow ? 1 : null,
                ),
              ),
            ]),
          ),
        ),
      );
    }
  }
}
