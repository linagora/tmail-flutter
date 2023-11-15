import 'package:core/presentation/views/bottom_popup/cupertino_action_sheet_no_icon_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/styles/email_sort_by_cupertino_action_sheet_action_builder_style.dart';

class EmailSortByCupertinoActionSheetActionBuilder extends CupertinoActionSheetNoIconBuilder<EmailSortOrderType> {
  final EmailSortOrderType sortType;
  final EmailSortOrderType? sortTypeCurrent;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsetsDirectional? iconLeftPadding;
  final EdgeInsetsDirectional? iconRightPadding;

  EmailSortByCupertinoActionSheetActionBuilder(
    String actionName,
    this.sortType,
    {
      Key? key,
      this.sortTypeCurrent,
      this.actionSelected,
      this.bgColor,
      this.iconLeftPadding,
      this.iconRightPadding,
    }
  ) : super(actionName);

  @override
  Widget build() {
    return Container(
      color: bgColor ?? EmailSortByCupertinoActionSheetActionBuilderStyle.backgroundColor,
      child: MouseRegion(
        cursor: PlatformInfo.isWeb ? MaterialStateMouseCursor.clickable : MouseCursor.defer,
        child: CupertinoActionSheetAction(
          key: key,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: EmailSortByCupertinoActionSheetActionBuilderStyle.space),
              Expanded(
                child: Text(
                  actionName,
                  textAlign: TextAlign.left,
                  style: actionTextStyle()
                ),
              ),
              if (sortTypeCurrent == sortType && actionSelected != null)
                Padding(
                  padding: iconRightPadding ?? EmailSortByCupertinoActionSheetActionBuilderStyle.iconPadding,
                  child: actionSelected!
                ),
            ]
          ),
          onPressed: () {
            if (onCupertinoActionSheetActionClick != null) {
              onCupertinoActionSheetActionClick!(sortType);
            }
          },
        ),
      ),
    );
  }
}