import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A builder which builds a reusable slogan widget.
/// This contains the logo and the slogan text.
/// The elements are arranged in a column or row.

typedef OnTapCallback = void Function();

class SloganBuilder extends StatelessWidget {

  final bool arrangedByHorizontal;
  final String? text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final String? logo;
  final Uri? publicLogoUri;
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
    this.publicLogoUri,
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
      return InkWell(
        onTap: onTapCallback,
        hoverColor: hoverColor,
        borderRadius: BorderRadius.all(Radius.circular(hoverRadius ?? 8)),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(children: [
            _logoApp(),
            Padding(
              padding: paddingText ?? const EdgeInsetsDirectional.only(top: 16, start: 16, end: 16),
              child: Text(
                text ?? '',
                style: textStyle,
                textAlign: textAlign,
                overflow: enableOverflow ? CommonTextStyle.defaultTextOverFlow : null,
                softWrap: enableOverflow ? CommonTextStyle.defaultSoftWrap : null,
                maxLines: enableOverflow ? 1 : null,
              ),
            ),
          ]),
        ),
      );
    } else {
      return InkWell(
        onTap: onTapCallback,
        hoverColor: hoverColor,
        radius: hoverRadius ?? 8,
        borderRadius: BorderRadius.all(Radius.circular(hoverRadius ?? 8)),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(children: [
            _logoApp(),
            Padding(
              padding: paddingText ?? const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                text ?? '',
                style: textStyle,
                textAlign: textAlign,
                overflow: enableOverflow ? CommonTextStyle.defaultTextOverFlow : null,
                softWrap: enableOverflow ? CommonTextStyle.defaultSoftWrap : null,
                maxLines: enableOverflow ? 1 : null,
              ),
            ),
          ]),
        ),
      );
    }
  }

  Widget _logoApp() {
    if (logo != null && logo!.endsWith('svg')) {
      return SvgPicture.asset(
        logo!,
        width: sizeLogo ?? 150,
        height: sizeLogo ?? 150);
    } else if (logo != null) {
      return Image(
        image: AssetImage(logo!),
        fit: BoxFit.fill,
        width: sizeLogo ?? 150,
        height: sizeLogo ?? 150);
    } else if (publicLogoUri != null) {
      return Image.network(
        publicLogoUri.toString(),
        fit: BoxFit.fill,
        width: sizeLogo ?? 150,
        height: sizeLogo ?? 150,
        errorBuilder: (_, error, stackTrace) {
          return Container(
            width: sizeLogo ?? 150,
            height: sizeLogo ?? 150,
            color: AppColor.textFieldHintColor,
          );
        });
    } else {
      return const SizedBox.shrink();
    }
  }
}
