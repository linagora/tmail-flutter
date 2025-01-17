import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/styles/popup_item_widget_style.dart';

class PopupItemWidget extends StatelessWidget {

  final String _iconAction;
  final String _nameAction;
  final Color? colorIcon;
  final double? iconSize;
  final TextStyle? styleName;
  final bool? isSelected;
  final String? selectedIcon;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onCallbackAction;

  const PopupItemWidget(
    this._iconAction,
    this._nameAction,
    {
      Key? key,
      this.colorIcon,
      this.iconSize,
      this.styleName,
      this.isSelected,
      this.padding,
      this.selectedIcon,
      this.onCallbackAction
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onCallbackAction,
          child: Container(
            height: PopupItemWidgetStyle.height,
            constraints: const BoxConstraints(minWidth: PopupItemWidgetStyle.minWidth),
            padding: padding,
            child: Row(children: [
              SvgPicture.asset(
                _iconAction,
                width: iconSize ?? PopupItemWidgetStyle.iconSize,
                height: iconSize ?? PopupItemWidgetStyle.iconSize,
                fit: BoxFit.fill,
                colorFilter: colorIcon?.asFilter()
              ),
              const SizedBox(width: PopupItemWidgetStyle.space),
              Expanded(child: Text(
                _nameAction,
                style: styleName ?? PopupItemWidgetStyle.labelTextStyle
              )),
              if (isSelected == true && selectedIcon != null)
                Padding(
                  padding: PopupItemWidgetStyle.iconSelectedPadding,
                  child: SvgPicture.asset(
                    selectedIcon!,
                    width: PopupItemWidgetStyle.selectedIconSize,
                    height: PopupItemWidgetStyle.selectedIconSize,
                    fit: BoxFit.fill
                  ),
                )
            ]),
          )
        ),
      ),
    );
  }
}