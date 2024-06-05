import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_action_button_widget_styles.dart';

typedef OnCalendarEventReplyActionClick = void Function(EventActionType eventActionType);

class CalendarEventActionButtonWidget extends StatelessWidget {

  final EdgeInsetsGeometry? margin;
  final OnCalendarEventReplyActionClick onCalendarEventReplyActionClick;
  final bool calendarEventReplying;
  final PresentationEmail? presentationEmail;
  final VoidCallback? onMailToAttendeesAction;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  CalendarEventActionButtonWidget({
    super.key,
    required this.onCalendarEventReplyActionClick,
    required this.calendarEventReplying,
    this.margin,
    this.presentationEmail,
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
        children: EventActionType.values
          .map((action) => AbsorbPointer(
            absorbing: _getCallbackFunction(action) == null,
            child: TMailButtonWidget(
              text: action.getLabelButton(context),
              backgroundColor: _getButtonBackgroundColor(action),
              borderRadius: CalendarEventActionButtonWidgetStyles.borderRadius,
              padding: CalendarEventActionButtonWidgetStyles.buttonPadding,
              textStyle: TextStyle(
                fontWeight: CalendarEventActionButtonWidgetStyles.fontWeight,
                fontSize: CalendarEventActionButtonWidgetStyles.textSize,
                color: _getButtonTextColor(action),
              ),
              textAlign: TextAlign.center,
              minWidth: CalendarEventActionButtonWidgetStyles.minWidth,
              width: _responsiveUtils.isPortraitMobile(context) ? double.infinity : null,
              border: Border.all(
                width: CalendarEventActionButtonWidgetStyles.borderWidth,
                color: _getButtonBorderColor(action)
              ),
              onTapActionCallback: _getCallbackFunction(action),
            )
          ))
          .toList(),
      ),
    );
  }

  Color _getButtonBackgroundColor(EventActionType eventActionType) {
    switch (eventActionType) {
      case EventActionType.yes:
        if (presentationEmail?.isAcceptedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        if (calendarEventReplying) {
          return CalendarEventActionButtonWidgetStyles.loadingBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.backgroundColor;
      case EventActionType.maybe:
        if (presentationEmail!.isTentativelyAcceptedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        if (calendarEventReplying) {
          return CalendarEventActionButtonWidgetStyles.loadingBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.backgroundColor;
      case EventActionType.no:
        if (presentationEmail?.isRejectedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        if (calendarEventReplying) {
          return CalendarEventActionButtonWidgetStyles.loadingBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.backgroundColor;
      case EventActionType.mailToAttendees:
        return CalendarEventActionButtonWidgetStyles.backgroundColor;
    }
  }

  Color _getButtonTextColor(EventActionType eventActionType) {
    switch (eventActionType) {
      case EventActionType.yes:
        if (presentationEmail?.isAcceptedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedTextColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.maybe:
        if (presentationEmail?.isTentativelyAcceptedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedTextColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.no:
        if (presentationEmail?.isRejectedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedTextColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.mailToAttendees:
        return CalendarEventActionButtonWidgetStyles.textColor;
    }
  }

  Color _getButtonBorderColor(EventActionType eventActionType) {
    switch (eventActionType) {
      case EventActionType.yes:
        if (presentationEmail?.isAcceptedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.maybe:
        if (presentationEmail?.isTentativelyAcceptedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.no:
        if (presentationEmail?.isRejectedEventAttendance == true) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.mailToAttendees:
        return CalendarEventActionButtonWidgetStyles.textColor;
    }
  }

  Function()? _getCallbackFunction(EventActionType eventActionType) {
    switch (eventActionType) {
      case EventActionType.yes:
        if (presentationEmail?.isAcceptedEventAttendance == true || calendarEventReplying) {
          return null;
        }
        return () => onCalendarEventReplyActionClick(eventActionType);
      case EventActionType.maybe:
        if (presentationEmail?.isTentativelyAcceptedEventAttendance == true || calendarEventReplying) {
          return null;
        }
        return () => onCalendarEventReplyActionClick(eventActionType);
      case EventActionType.no:
        if (presentationEmail?.isRejectedEventAttendance == true || calendarEventReplying) {
          return null;
        }
        return () => onCalendarEventReplyActionClick(eventActionType);
      case EventActionType.mailToAttendees:
        return onMailToAttendeesAction;
    }
  }
}