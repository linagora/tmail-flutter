import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class PopupMenuItemWidget extends StatelessWidget {

  final String name;
  final String? icon;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? textStyle;
  final String? iconSelected;
  final EdgeInsetsGeometry? padding;
  final double? space;
  final double? height;
  final VoidCallback? onCallbackAction;

  const PopupMenuItemWidget({
    Key? key,
    required this.name,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.textStyle,
    this.iconSelected,
    this.padding,
    this.space,
    this.height,
    this.onCallbackAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: InkWell(
        onTap: onCallbackAction,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
          height: height,
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(end: space ?? 8),
                  child: SvgPicture.asset(
                    icon!,
                    width: iconSize ?? 20,
                    height: iconSize ?? 20,
                    fit: BoxFit.fill,
                    colorFilter: iconColor?.asFilter()
                  ),
                ),
              Expanded(
                child: Text(
                  name,
                  style: textStyle ?? Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black87,
                    fontSize: 15
                  )
                )
              ),
              if (iconSelected != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: space ?? 8),
                  child: SvgPicture.asset(
                    iconSelected!,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill
                  ),
                )
            ]
          ),
        )
      ),
    );
  }
}