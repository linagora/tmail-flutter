
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

mixin PopupMenuWidgetMixin {

  Widget popupItem(
    String iconAction,
    String nameAction, {
    Color? colorIcon,
    double? iconSize,
    TextStyle? styleName,
    EdgeInsets? padding,
    Function()? onCallbackAction
  }) {
    return InkWell(
      onTap: onCallbackAction,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          child: Row(children: [
            SvgPicture.asset(
              iconAction,
              width: iconSize ?? 20,
              height: iconSize ?? 20,
              fit: BoxFit.fill,
              colorFilter: colorIcon.asFilter()
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(
              nameAction,
              style: styleName ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.normal,
                color: Colors.black)
            )),
          ])
        ),
      )
    );
  }
}