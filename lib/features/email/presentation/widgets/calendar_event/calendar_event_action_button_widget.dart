
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_action_button_widget_styles.dart';

typedef OnCalendarEventReplyActionClick = void Function(EventActionType eventActionType);

class CalendarEventActionButtonWidget extends StatelessWidget {

  final EdgeInsetsGeometry? margin;
  final OnCalendarEventReplyActionClick onCalendarEventReplyActionClick;
  final bool calendarEventReplying;

  const CalendarEventActionButtonWidget({
    super.key,
    required this.onCalendarEventReplyActionClick,
    required this.calendarEventReplying,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    return Container(
      width: double.infinity,
      margin: margin ?? CalendarEventActionButtonWidgetStyles.margin,
      padding: responsiveUtils.isPortraitMobile(context)
        ? CalendarEventActionButtonWidgetStyles.paddingMobile
        : CalendarEventActionButtonWidgetStyles.paddingWeb,
      child: Wrap(
        spacing: CalendarEventActionButtonWidgetStyles.space,
        runSpacing: CalendarEventActionButtonWidgetStyles.space,
        children: EventActionType.values
          .map((action) => TMailButtonWidget(
            text: action.getLabelButton(context),
            backgroundColor: calendarEventReplying
              ? CalendarEventActionButtonWidgetStyles.loadingBackgroundColor
              : CalendarEventActionButtonWidgetStyles.backgroundColor,
            borderRadius: CalendarEventActionButtonWidgetStyles.borderRadius,
            padding: CalendarEventActionButtonWidgetStyles.buttonPadding,
            textStyle: const TextStyle(
              fontWeight: CalendarEventActionButtonWidgetStyles.fontWeight,
              fontSize: CalendarEventActionButtonWidgetStyles.textSize,
              color: CalendarEventActionButtonWidgetStyles.textColor,
            ),
            textAlign: TextAlign.center,
            minWidth: CalendarEventActionButtonWidgetStyles.minWidth,
            width: responsiveUtils.isPortraitMobile(context) ? double.infinity : null,
            border: Border.all(
              width: CalendarEventActionButtonWidgetStyles.borderWidth,
              color: CalendarEventActionButtonWidgetStyles.textColor
            ),
            onTapActionCallback: calendarEventReplying
              ? null
              : () => onCalendarEventReplyActionClick(action),
          ))
          .toList(),
      ),
    );
  }
}