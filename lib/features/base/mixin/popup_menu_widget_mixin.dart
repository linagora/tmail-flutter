
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

mixin PopupMenuWidgetMixin {

  Widget popupItem(String iconAction, String nameAction, {
    Color? colorIcon,
    TextStyle? styleName,
    Function? onCallbackAction
  }) {
    return InkWell(
        onTap: () => onCallbackAction?.call(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
              child: Row(children: [
                SvgPicture.asset(iconAction, width: 20, height: 20, fit: BoxFit.fill, color: colorIcon),
                const SizedBox(width: 12),
                Expanded(child: Text(nameAction,
                    style: styleName ?? const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: Colors.black))),
              ])
          ),
        )
    );
  }
}