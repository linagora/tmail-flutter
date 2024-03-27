
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_action_button_widget_styles.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class CalendarEventActionButtonWidget extends StatelessWidget {

  final List<EventAction> eventActions;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onMailToAttendeesAction;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  CalendarEventActionButtonWidget({
    super.key,
    required this.eventActions,
    this.margin,
    this.onMailToAttendeesAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? CalendarEventActionButtonWidgetStyles.margin,
      padding: _responsiveUtils.isPortraitMobile(context)
        ? CalendarEventActionButtonWidgetStyles.paddingMobile
        : CalendarEventActionButtonWidgetStyles.paddingWeb,
      child: Wrap(
        spacing: CalendarEventActionButtonWidgetStyles.space,
        runSpacing: CalendarEventActionButtonWidgetStyles.space,
        children: eventActions
          .map((action) => TMailButtonWidget(
            text: action.actionType.getLabelButton(context),
            backgroundColor: CalendarEventActionButtonWidgetStyles.backgroundColor,
            borderRadius: CalendarEventActionButtonWidgetStyles.borderRadius,
            padding: CalendarEventActionButtonWidgetStyles.buttonPadding,
            textStyle: const TextStyle(
              fontWeight: CalendarEventActionButtonWidgetStyles.fontWeight,
              fontSize: CalendarEventActionButtonWidgetStyles.textSize,
              color: CalendarEventActionButtonWidgetStyles.textColor,
            ),
            textAlign: TextAlign.center,
            minWidth: CalendarEventActionButtonWidgetStyles.minWidth,
            width: _responsiveUtils.isPortraitMobile(context) ? double.infinity : null,
            border: Border.all(
              width: CalendarEventActionButtonWidgetStyles.borderWidth,
              color: CalendarEventActionButtonWidgetStyles.textColor
            ),
            onTapActionCallback: () {
              if (action.actionType == EventActionType.mailToAttendees) {
                onMailToAttendeesAction?.call();
              } else {
                AppUtils.launchLink(action.link);
              }
            },
          ))
          .toList(),
      ),
    );
  }
}