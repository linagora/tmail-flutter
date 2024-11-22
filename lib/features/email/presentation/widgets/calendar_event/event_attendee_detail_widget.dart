
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/list_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_attendee_detail_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/attendee_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/hide_all_attendees_button_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/organizer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/see_all_attendees_button_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventAttendeeDetailWidget extends StatefulWidget {

  static const int maxAttendeeDisplayed = 6;

  final List<CalendarAttendee> attendees;
  final CalendarOrganizer? organizer;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;

  const EventAttendeeDetailWidget({
    super.key,
    required this.attendees,
    required this.organizer,
    this.openEmailAddressDetailAction,
  });

  @override
  State<EventAttendeeDetailWidget> createState() => _EventAttendeeDetailWidgetState();
}

class _EventAttendeeDetailWidgetState extends State<EventAttendeeDetailWidget> {

  late List<CalendarAttendee> _attendeesDisplayed;
  late bool _isShowAllAttendee;

  @override
  void initState() {
    super.initState();
    _attendeesDisplayed = _splitAttendees(widget.attendees);
    _isShowAllAttendee = widget.attendees.length <= EventAttendeeDetailWidget.maxAttendeeDisplayed;
    log('_EventAttendeeDetailWidgetState::initState:attendees: ${widget.attendees.length} | _isShowAllAttendee: $_isShowAllAttendee');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventAttendeeDetailWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).who,
            style: const TextStyle(
              fontSize: EventAttendeeDetailWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventAttendeeDetailWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.organizer != null)
              OrganizerWidget(
                organizer: widget.organizer!,
                openEmailAddressDetailAction: widget.openEmailAddressDetailAction
              ),
            if (_attendeesDisplayed.isNotEmpty)
              ..._attendeesDisplayed
                  .map((attendee) => AttendeeWidget(
                    attendee: attendee,
                    listAttendees: _attendeesDisplayed,
                    openEmailAddressDetailAction: widget.openEmailAddressDetailAction
                  ))
                  .toList(),
            if (!_isShowAllAttendee)
              Padding(
                padding: const EdgeInsets.only(top: EventAttendeeDetailWidgetStyles.fieldTopPadding),
                child: SeeAllAttendeesButtonWidget(
                  onTap: () {
                    setState(() {
                      _attendeesDisplayed = widget.attendees.withoutOrganizer(widget.organizer);
                      _isShowAllAttendee = true;
                    });
                  }
                ),
              )
            else if (widget.attendees.length > EventAttendeeDetailWidget.maxAttendeeDisplayed)
              Padding(
                padding: const EdgeInsets.only(top: EventAttendeeDetailWidgetStyles.fieldTopPadding),
                child: HideAllAttendeesButtonWidget(
                  onTap: () {
                    setState(() {
                      _attendeesDisplayed = _splitAttendees(widget.attendees);
                      _isShowAllAttendee = false;
                    });
                  }
                ),
              )
          ]
        ))
      ],
    );
  }

  List<CalendarAttendee> _splitAttendees(List<CalendarAttendee> attendees) {
    final attendeesWithoutOrganizer = attendees.withoutOrganizer(widget.organizer);
    return attendeesWithoutOrganizer.length > EventAttendeeDetailWidget.maxAttendeeDisplayed
      ? attendeesWithoutOrganizer.sublist(0, EventAttendeeDetailWidget.maxAttendeeDisplayed - 1)
      : attendeesWithoutOrganizer;
  }
}