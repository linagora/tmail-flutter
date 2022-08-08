import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class EmailRuleBottomSheetActionTileBuilder
    extends CupertinoActionSheetActionBuilder<TMailRule> {
  final TMailRule emailRule;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;
  final EdgeInsets? iconRightPadding;
  final TextStyle? textStyleAction;

  EmailRuleBottomSheetActionTileBuilder(
    Key key,
    SvgPicture actionIcon,
    String actionName,
    this.emailRule, {
    this.actionSelected,
    this.bgColor,
    this.iconLeftPadding,
    this.iconRightPadding,
    this.textStyleAction,
  }) : super(key, actionIcon, actionName);

  @override
  Widget build() {
    return Container(
      color: bgColor ?? Colors.white,
      child: MouseRegion(
        cursor: BuildUtils.isWeb
            ? MaterialStateMouseCursor.clickable
            : MouseCursor.defer,
        child: CupertinoActionSheetAction(
          key: key,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
                padding: iconLeftPadding ??
                    const EdgeInsets.only(left: 12, right: 16),
                child: actionIcon),
            Expanded(
                child: Text(actionName,
                    textAlign: TextAlign.left,
                    style: actionTextStyle(textStyle: textStyleAction))),
          ]),
          onPressed: () {
            if (onCupertinoActionSheetActionClick != null) {
              onCupertinoActionSheetActionClick!(emailRule);
            }
          },
        ),
      ),
    );
  }
}
