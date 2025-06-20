import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_detail_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_information_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_date_icon_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_button_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_attendee_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_link_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_location_information_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_time_information_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_title_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnOpenNewTabAction = void Function(String link);
typedef OnOpenComposerAction = void Function(String emailAddress);

class CalendarEventInformationWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final OnOpenNewTabAction? onOpenNewTabAction;
  final OnOpenComposerAction? onOpenComposerAction;
  final OnCalendarEventReplyActionClick onCalendarEventReplyActionClick;
  final bool calendarEventReplying;
  final AttendanceStatus? attendanceStatus;
  final OnMailtoAttendeesAction? onMailtoAttendeesAction;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;
  final bool isFree;
  final List<String> listEmailAddressSender;
  final String ownEmailAddress;
  final bool isPortraitMobile;

  const CalendarEventInformationWidget({
    super.key,
    required this.calendarEvent,
    required this.onCalendarEventReplyActionClick,
    required this.calendarEventReplying,
    required this.isFree,
    required this.ownEmailAddress,
    this.onOpenNewTabAction,
    this.onOpenComposerAction,
    this.attendanceStatus,
    this.onMailtoAttendeesAction,
    this.openEmailAddressDetailAction,
    this.listEmailAddressSender = const [],
    this.isPortraitMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final bodyBorderRadius = isPortraitMobile
        ? const BorderRadiusDirectional.only(
            bottomStart: CalendarEventInformationWidgetStyles.radius,
            bottomEnd: CalendarEventInformationWidgetStyles.radius,
          )
        : const BorderRadiusDirectional.only(
            topEnd: CalendarEventInformationWidgetStyles.radius,
            bottomEnd: CalendarEventInformationWidgetStyles.radius,
          );

    final eventActionTypes = calendarEvent.getEventActionTypesIsDisplayed(
      ownEmailAddress,
    );

    final bodyWidget = Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: bodyBorderRadius),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(
        CalendarEventInformationWidgetStyles.calendarInformationMargin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calendarEvent.organizerName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: CalendarEventInformationWidgetStyles.space,
              ),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: CalendarEventInformationWidgetStyles
                        .invitationMessageTextSize,
                    fontWeight: FontWeight.w500,
                    color: CalendarEventInformationWidgetStyles
                        .invitationMessageColor,
                  ),
                  children: [
                    TextSpan(
                      text: calendarEvent.organizerName,
                      style: const TextStyle(
                        color: CalendarEventInformationWidgetStyles
                            .invitationMessageColor,
                        fontSize: CalendarEventInformationWidgetStyles
                            .invitationMessageTextSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: calendarEvent.getTitleEventAction(
                        context,
                        listEmailAddressSender,
                      ),
                    )
                  ],
                ),
              ),
            ),
          if (calendarEvent.title?.isNotEmpty == true)
            EventTitleWidget(title: calendarEvent.title!),
          _buildEventTimeInformationWidget(),
          if (calendarEvent.location?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(
                top: CalendarEventInformationWidgetStyles.fieldTopPadding,
              ),
              child: EventLocationInformationWidget(
                locationEvent: calendarEvent.location!,
                onOpenComposerAction: onOpenComposerAction,
                onOpenNewTabAction: onOpenNewTabAction,
              ),
            ),
          if (calendarEvent.videoConferences.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: CalendarEventDetailWidgetStyles.fieldTopPadding,
              ),
              child: EventLinkDetailWidget(
                listHyperLink: calendarEvent.videoConferences,
              ),
            ),
          if (calendarEvent.participants?.isNotEmpty == true ||
              calendarEvent.organizer != null)
            Padding(
              padding: const EdgeInsets.only(
                top: CalendarEventDetailWidgetStyles.fieldTopPadding,
              ),
              child: EventAttendeeDetailWidget(
                attendees: calendarEvent.participants ?? [],
                organizer: calendarEvent.organizer,
                openEmailAddressDetailAction: openEmailAddressDetailAction,
              ),
            ),
          if (calendarEvent.isDisplayedWarningMessage(ownEmailAddress))
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: CalendarEventInformationWidgetStyles.fieldTopPadding,
                start: isPortraitMobile ? 0 : 100,
              ),
              child: Text(
                AppLocalizations
                    .of(context)
                    .youAreNotInvitedToThisEventPleaseContactTheOrganizer,
                style: const TextStyle(
                  fontSize: CalendarEventInformationWidgetStyles
                      .invitationMessageTextSize,
                  fontWeight: FontWeight.w500,
                  color: AppColor.colorMaybeEventActionText,
                ),
              ),
            ),
          if (eventActionTypes.isNotEmpty)
            CalendarEventActionButtonWidget(
              eventActions: eventActionTypes,
              onCalendarEventReplyActionClick: onCalendarEventReplyActionClick,
              calendarEventReplying: calendarEventReplying,
              attendanceStatus: attendanceStatus,
              isPortraitMobile: isPortraitMobile,
              onMailToAttendeesAction: () => onMailtoAttendeesAction?.call(
                calendarEvent.organizer,
                calendarEvent.participants,
              ),
            ),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: AppColor.colorCalendarEventInformationBackground,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.5,
            color: AppColor.colorCalendarEventInformationStroke,
          ),
          borderRadius: BorderRadius.all(
            CalendarEventInformationWidgetStyles.radius,
          ),
        ),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        vertical: CalendarEventInformationWidgetStyles.verticalMargin,
        horizontal: CalendarEventInformationWidgetStyles.horizontalMargin),
      child: isPortraitMobile
        ? Column(
            children: [
              CalendarDateIconWidget(
                calendarEvent: calendarEvent,
                width: double.infinity,
              ),
              bodyWidget,
            ],
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarDateIconWidget(calendarEvent: calendarEvent),
                Expanded(child: bodyWidget),
              ],
            ),
          ),
    );
  }

  Widget _buildEventTimeInformationWidget() {
    final dateTimeEvent = calendarEvent.getDateTimeEvent(
      dateLocale: AppUtils.getCurrentDateLocale(),
      timeZone: AppUtils.getTimeZone()
    );
    if (dateTimeEvent.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: CalendarEventInformationWidgetStyles.fieldTopPadding),
        child: EventTimeInformationWidget(
          timeEvent: dateTimeEvent,
          isFree: isFree,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}