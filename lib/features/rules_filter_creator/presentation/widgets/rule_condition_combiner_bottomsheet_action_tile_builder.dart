import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_condition_combiner.dart';

class RuleConditionCombinerSheetActionTileBuilder
    extends CupertinoActionSheetNoIconBuilder<ConditionCombiner> {

  final ConditionCombiner combiner;
  final ConditionCombiner? combinerCurrent;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;
  final EdgeInsets? iconRightPadding;

  RuleConditionCombinerSheetActionTileBuilder(
      String actionName,
      this.combiner,
      this.combinerCurrent,
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
        cursor: PlatformInfo.isWeb
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
              if (combinerCurrent == combiner && actionSelected != null)
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
              onCupertinoActionSheetActionClick!(combiner);
            }
          },
        ),
      ),
    );
  }
}