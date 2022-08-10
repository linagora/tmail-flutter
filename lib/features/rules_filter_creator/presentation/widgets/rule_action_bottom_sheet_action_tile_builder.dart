
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';

class RuleActionSheetActionTileBuilder
    extends CupertinoActionSheetNoIconBuilder<EmailRuleFilterAction> {

  final EmailRuleFilterAction ruleAction;
  final EmailRuleFilterAction? ruleActionCurrent;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsets? iconLeftPadding;
  final EdgeInsets? iconRightPadding;

  RuleActionSheetActionTileBuilder(
      String actionName,
      this.ruleActionCurrent,
      this.ruleAction,
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
              if (ruleActionCurrent == ruleAction && actionSelected != null)
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
              onCupertinoActionSheetActionClick!(ruleAction);
            }
          },
        ),
      ),
    );
  }
}