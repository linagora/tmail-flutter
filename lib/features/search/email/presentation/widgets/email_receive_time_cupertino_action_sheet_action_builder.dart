
import 'package:core/presentation/views/bottom_popup/cupertino_action_sheet_no_icon_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';

class EmailReceiveTimeCupertinoActionSheetActionBuilder
    extends CupertinoActionSheetNoIconBuilder<EmailReceiveTimeType> {

  final EmailReceiveTimeType timeType;
  final EmailReceiveTimeType? timeTypeCurrent;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsetsGeometry? iconLeftPadding;
  final EdgeInsetsGeometry? iconRightPadding;

  EmailReceiveTimeCupertinoActionSheetActionBuilder(
      String actionName,
      this.timeType, {
      Key? key,
      this.timeTypeCurrent,
      this.actionSelected,
      this.bgColor,
      this.iconLeftPadding,
      this.iconRightPadding,
  }) : super(actionName);

  @override
  Widget build() {
    return Container(
      color: bgColor ?? Colors.white,
      child: MouseRegion(
        cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
        child: CupertinoActionSheetAction(
          key: key,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: 16),
            Expanded(child: Text(actionName, textAlign: TextAlign.left, style: actionTextStyle())),
            if (timeTypeCurrent == timeType && actionSelected != null)
              Padding(
                  padding: iconRightPadding ?? const EdgeInsets.only(right: 16),
                  child: actionSelected!),
          ]),
          onPressed: () {
            if (onCupertinoActionSheetActionClick != null) {
              onCupertinoActionSheetActionClick!(timeType);
            }
          },
        ),
      ),
    );
  }
}