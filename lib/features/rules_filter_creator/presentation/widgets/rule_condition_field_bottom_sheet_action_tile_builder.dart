
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;

class RuleConditionFieldSheetActionTileBuilder
    extends CupertinoActionSheetNoIconBuilder<rule_condition.Field> {

  final rule_condition.Field field;
  final rule_condition.Field? fieldCurrent;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;
  final EdgeInsets? iconRightPadding;

  RuleConditionFieldSheetActionTileBuilder(
      String actionName,
      this.fieldCurrent,
      this.field,
      {
        Key? key,
        this.actionSelected,
        this.bgColor,
        this.iconLeftPadding,
        this.iconRightPadding,
      }
  ) : super(actionName, key: key);

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
          child: Stack(
            children: [
              Center(
                child: Text(actionName,
                  textAlign: TextAlign.center,
                  style: actionTextStyle()),
              ),
              if (fieldCurrent == field && actionSelected != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: iconRightPadding ??
                          const EdgeInsets.only(right: 12),
                      child: actionSelected!),
                ),
            ],
          ),
          onPressed: () {
            if (onCupertinoActionSheetActionClick != null) {
              onCupertinoActionSheetActionClick!(field);
            }
          },
        ),
      ),
    );
  }
}