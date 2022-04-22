
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:model/model.dart';

class FilterMessageCupertinoActionSheetActionBuilder extends CupertinoActionSheetActionBuilder<FilterMessageOption> {

  final FilterMessageOption option;
  final FilterMessageOption? optionCurrent;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;
  final EdgeInsets? iconRightPadding;

  FilterMessageCupertinoActionSheetActionBuilder(
      Key key,
      SvgPicture actionIcon,
      String actionName,
      this.option,
      {
        this.optionCurrent,
        this.actionSelected,
        this.bgColor,
        this.iconLeftPadding,
        this.iconRightPadding,
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
          if (optionCurrent == option && actionSelected != null)
            Padding(
              padding: iconRightPadding ?? const EdgeInsets.only(right: 12),
              child: actionSelected!),
        ]),
        onPressed: () {
          if (onCupertinoActionSheetActionClick != null) {
            onCupertinoActionSheetActionClick!(option);
          }
        },
      ),
    );
  }
}