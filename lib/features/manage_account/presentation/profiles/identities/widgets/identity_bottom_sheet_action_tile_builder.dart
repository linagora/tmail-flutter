
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class IdentityBottomSheetActionTileBuilder extends CupertinoActionSheetActionBuilder<Identity> {

  final Identity identity;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;
  final EdgeInsets? iconRightPadding;

  IdentityBottomSheetActionTileBuilder(
      Key key,
      SvgPicture actionIcon,
      String actionName,
      this.identity,
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
            onCupertinoActionSheetActionClick!(identity);
          }
        },
      ),
    );
  }
}