
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppActionSheetActionBuilder extends CupertinoActionSheetActionBuilder {

  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;

  AppActionSheetActionBuilder(
      Key key,
      SvgPicture actionIcon,
      String actionName,
      {
        this.bgColor,
        this.iconLeftPadding,
      }
  ) : super(key, actionIcon, actionName);

  @override
  Widget build() {
    return Container(
      color: bgColor ?? Colors.white,
      child: CupertinoActionSheetAction(
        key: key,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: iconLeftPadding ?? const EdgeInsets.only(left: 12, right: 16),
              child: actionIcon),
          Expanded(child: Text(actionName, textAlign: TextAlign.left, style: actionTextStyle())),
        ]),
        onPressed: () => onCupertinoActionSheetActionClick?.call(null),
      ),
    );
  }
}