
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:model/model.dart';

class EmailActionCupertinoActionSheetActionBuilder extends CupertinoActionSheetActionBuilder<PresentationEmail> {

  final PresentationEmail presentationEmail;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;
  final EdgeInsets? iconRightPadding;

  EmailActionCupertinoActionSheetActionBuilder(
      Key key,
      SvgPicture actionIcon,
      String actionName,
      this.presentationEmail,
      {
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
        ]),
        onPressed: () {
          if (onCupertinoActionSheetActionClick != null) {
            onCupertinoActionSheetActionClick!(presentationEmail);
          }
        },
      ),
    );
  }
}