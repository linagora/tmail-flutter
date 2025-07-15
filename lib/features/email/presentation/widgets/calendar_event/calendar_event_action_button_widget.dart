import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_action_button_widget_styles.dart';

typedef OnCalendarEventReplyActionClick = void Function(EventActionType eventActionType);

class CalendarEventActionButtonWidget extends StatelessWidget {

  final List<EventActionType> eventActions;
  final OnCalendarEventReplyActionClick onCalendarEventReplyActionClick;
  final bool calendarEventReplying;
  final AttendanceStatus? attendanceStatus;
  final bool isPortraitMobile;
  final VoidCallback? onMailToAttendeesAction;

  const CalendarEventActionButtonWidget({
    super.key,
    required this.eventActions,
    required this.onCalendarEventReplyActionClick,
    required this.calendarEventReplying,
    this.attendanceStatus,
    this.isPortraitMobile = false,
    this.onMailToAttendeesAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: isPortraitMobile
        ? CalendarEventActionButtonWidgetStyles.paddingMobile
        : CalendarEventActionButtonWidgetStyles.paddingWeb,
      child: Wrap(
        spacing: CalendarEventActionButtonWidgetStyles.space,
        runSpacing: CalendarEventActionButtonWidgetStyles.space,
        children: eventActions
          .map((action) => AbsorbPointer(
            absorbing: _getCallbackFunction(action) == null,
            child: TMailButtonWidget(
              text: action.getLabelButton(context),
              backgroundColor: _getButtonBackgroundColor(action),
              borderRadius: CalendarEventActionButtonWidgetStyles.borderRadius,
              padding: CalendarEventActionButtonWidgetStyles.buttonPadding,
              textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontWeight: CalendarEventActionButtonWidgetStyles.fontWeight,
                fontSize: CalendarEventActionButtonWidgetStyles.textSize,
                color: _getButtonTextColor(action),
              ),
              textAlign: TextAlign.center,
              minWidth: CalendarEventActionButtonWidgetStyles.minWidth,
              width: isPortraitMobile ? double.infinity : null,
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
        if (attendanceStatus == AttendanceStatus.accepted) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        if (calendarEventReplying) {
          return CalendarEventActionButtonWidgetStyles.loadingBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.backgroundColor;
      case EventActionType.maybe:
        if (attendanceStatus == AttendanceStatus.tentativelyAccepted) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        if (calendarEventReplying) {
          return CalendarEventActionButtonWidgetStyles.loadingBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.backgroundColor;
      case EventActionType.no:
        if (attendanceStatus == AttendanceStatus.rejected) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        if (calendarEventReplying) {
          return CalendarEventActionButtonWidgetStyles.loadingBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.backgroundColor;
      case EventActionType.mailToAttendees:
      case EventActionType.acceptCounter:
        return CalendarEventActionButtonWidgetStyles.backgroundColor;
    }
  }

  Color _getButtonTextColor(EventActionType eventActionType) {
    switch (eventActionType) {
      case EventActionType.yes:
        if (attendanceStatus == AttendanceStatus.accepted) {
          return CalendarEventActionButtonWidgetStyles.selectedTextColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.maybe:
        if (attendanceStatus == AttendanceStatus.tentativelyAccepted) {
          return CalendarEventActionButtonWidgetStyles.selectedTextColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.no:
        if (attendanceStatus == AttendanceStatus.rejected) {
          return CalendarEventActionButtonWidgetStyles.selectedTextColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.mailToAttendees:
      case EventActionType.acceptCounter:
        return CalendarEventActionButtonWidgetStyles.textColor;
    }
  }

  Color _getButtonBorderColor(EventActionType eventActionType) {
    switch (eventActionType) {
      case EventActionType.yes:
        if (attendanceStatus == AttendanceStatus.accepted) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.maybe:
        if (attendanceStatus == AttendanceStatus.tentativelyAccepted) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.no:
        if (attendanceStatus == AttendanceStatus.rejected) {
          return CalendarEventActionButtonWidgetStyles.selectedBackgroundColor;
        }

        return CalendarEventActionButtonWidgetStyles.textColor;
      case EventActionType.mailToAttendees:
      case EventActionType.acceptCounter:
        return CalendarEventActionButtonWidgetStyles.textColor;
    }
  }

  Function()? _getCallbackFunction(EventActionType eventActionType) {
    switch (eventActionType) {
      case EventActionType.yes:
        if (attendanceStatus == AttendanceStatus.accepted || calendarEventReplying) {
          return null;
        }
        return () => onCalendarEventReplyActionClick(eventActionType);
      case EventActionType.acceptCounter:
        return () => onCalendarEventReplyActionClick(eventActionType);
      case EventActionType.maybe:
        if (attendanceStatus == AttendanceStatus.tentativelyAccepted || calendarEventReplying) {
          return null;
        }
        return () => onCalendarEventReplyActionClick(eventActionType);
      case EventActionType.no:
        if (attendanceStatus == AttendanceStatus.rejected || calendarEventReplying) {
          return null;
        }
        return () => onCalendarEventReplyActionClick(eventActionType);
      case EventActionType.mailToAttendees:
        return onMailToAttendeesAction;
    }
  }
}