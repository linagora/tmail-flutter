
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MailboxBottomSheetActionTileBuilder extends CupertinoActionSheetActionBuilder<PresentationMailbox> {

  final PresentationMailbox presentationMailbox;
  final SvgPicture? actionSelected;
  final Color? bgColor;
  final EdgeInsetsGeometry? iconLeftPadding;
  final EdgeInsetsGeometry? iconRightPadding;
  final bool opacity;
  final bool absorbing;

  MailboxBottomSheetActionTileBuilder(
      Key key,
      SvgPicture actionIcon,
      String actionName,
      this.presentationMailbox,
      {
        this.actionSelected,
        this.bgColor,
        this.iconLeftPadding,
        this.iconRightPadding,
        this.opacity = false,
        this.absorbing = false,
      }
  ) : super(key, actionIcon, actionName);

  @override
  Widget build() {
    return PointerInterceptor(
      child: AbsorbPointer(
        absorbing: absorbing,
        child: Opacity(
          opacity: opacity ? 0.3 : 1.0,
          child: Container(
            color: bgColor ?? Colors.white,
            child: MouseRegion(
              cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
              child: CupertinoActionSheetAction(
                key: key,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: iconLeftPadding ??
                        const EdgeInsetsDirectional.only(start: 12, end: 16),
                    child: actionIcon,
                  ),
                  Expanded(child: Text(actionName, textAlign: TextAlign.left, style: actionTextStyle())),
                ]),
                onPressed: () {
                  if (onCupertinoActionSheetActionClick != null) {
                    onCupertinoActionSheetActionClick!(presentationMailbox);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}