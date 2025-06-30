import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_detail_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_body_content_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_title_widget.dart';

typedef OnMailtoAttendeesAction = Function(CalendarOrganizer? organizer, List<CalendarAttendee>? participants);

class CalendarEventDetailWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final String emailContent;
  final bool? isDraggableAppActive;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final PresentationEmail? presentationEmail;
  final ScrollController? scrollController;
  final bool isInsideThreadDetailView;

  const CalendarEventDetailWidget({
    super.key,
    required this.calendarEvent,
    required this.emailContent,
    this.isDraggableAppActive,
    this.onMailtoDelegateAction,
    this.presentationEmail,
    this.scrollController,
    this.isInsideThreadDetailView = false,
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
          if (eventDesc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventBodyContentWidget(
                content: eventDesc,
                isDraggableAppActive: isDraggableAppActive,
                onMailtoDelegateAction: onMailtoDelegateAction,
                scrollController: scrollController,
                isInsideThreadDetailView: isInsideThreadDetailView,
              )
            ),
        ],
      ),
    );
  }
}
