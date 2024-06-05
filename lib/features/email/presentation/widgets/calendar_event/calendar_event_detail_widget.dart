import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_detail_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_button_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_attendee_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_body_content_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_link_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_location_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_time_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_title_widget.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnMailtoAttendeesAction = Function(CalendarOrganizer? organizer, List<CalendarAttendee>? participants);

class CalendarEventDetailWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final String emailContent;
  final OnOpenNewTabAction? onOpenNewTabAction;
  final OnOpenComposerAction? onOpenComposerAction;
  final bool? isDraggableAppActive;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final OnCalendarEventReplyActionClick onCalendarEventReplyActionClick;
  final bool calendarEventReplying;
  final PresentationEmail? presentationEmail;
  final OnMailtoAttendeesAction? onMailtoAttendeesAction;

  const CalendarEventDetailWidget({
    super.key,
    required this.calendarEvent,
    required this.emailContent,
    required this.onCalendarEventReplyActionClick,
    required this.calendarEventReplying,
    this.isDraggableAppActive,
    this.onOpenNewTabAction,
    this.onOpenComposerAction,
    this.onMailtoDelegateAction,
    this.presentationEmail,
    this.onMailtoAttendeesAction,
  });

  @override
  Widget build(BuildContext context) {
    final eventDesc = calendarEvent.description?.isNotEmpty == true
      ? calendarEvent.description!
      : emailContent;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: CalendarEventDetailWidgetStyles.borderStrokeWidth,
            color: CalendarEventDetailWidgetStyles.borderStrokeColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(CalendarEventDetailWidgetStyles.borderRadius)),
        ),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        vertical: CalendarEventDetailWidgetStyles.verticalMargin,
        horizontal: CalendarEventDetailWidgetStyles.horizontalMargin),
      padding: const EdgeInsets.all(CalendarEventDetailWidgetStyles.contentPadding),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calendarEvent.title?.isNotEmpty == true)
            EventTitleWidget(title: calendarEvent.title!),
          Padding(
            padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
            child: EventBodyContentWidget(
              content: eventDesc,
              isDraggableAppActive: isDraggableAppActive,
              onMailtoDelegateAction: onMailtoDelegateAction)),
          _buildEventTimeWidget(),
          if (calendarEvent.videoConferences.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventLinkDetailWidget(listHyperLink: calendarEvent.videoConferences),
            ),
          if (calendarEvent.location?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventLocationDetailWidget(
                locationEvent: calendarEvent.location!,
                onOpenComposerAction: onOpenComposerAction,
                onOpenNewTabAction: onOpenNewTabAction,
              ),
            ),
          if (calendarEvent.participants?.isNotEmpty == true && calendarEvent.organizer != null)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventAttendeeDetailWidget(
                attendees: calendarEvent.participants!,
                organizer: calendarEvent.organizer!,
              ),
            ),
          CalendarEventActionButtonWidget(
            onCalendarEventReplyActionClick: onCalendarEventReplyActionClick,
            calendarEventReplying: calendarEventReplying,
            presentationEmail: presentationEmail,
            onMailToAttendeesAction: () => onMailtoAttendeesAction?.call(
              calendarEvent.organizer,
              calendarEvent.participants,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTimeWidget() {
    final dateTimeEvent = calendarEvent.getDateTimeEvent(
      dateLocale: AppUtils.getCurrentDateLocale(),
      timeZone: AppUtils.getTimeZone()
    );
    if (dateTimeEvent.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
        child: EventTimeWidgetWidget(timeEvent: dateTimeEvent),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
