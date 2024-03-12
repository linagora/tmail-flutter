
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_information_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_date_icon_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_button_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_attendee_information_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_location_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_location_information_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_time_information_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_title_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class CalendarEventInformationWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final List<EventAction> eventActions;
  final OnOpenNewTabAction? onOpenNewTabAction;
  final OnOpenComposerAction? onOpenComposerAction;
  final OnMailtoAttendeesAction? onMailtoAttendeesAction;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  CalendarEventInformationWidget({
    super.key,
    required this.calendarEvent,
    required this.eventActions,
    this.onOpenNewTabAction,
    this.onOpenComposerAction,
    this.onMailtoAttendeesAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: AppColor.colorCalendarEventInformationBackground,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.5,
            color: AppColor.colorCalendarEventInformationStroke,
          ),
          borderRadius: BorderRadius.all(Radius.circular(CalendarEventInformationWidgetStyles.borderRadius)),
        ),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        vertical: CalendarEventInformationWidgetStyles.verticalMargin,
        horizontal: CalendarEventInformationWidgetStyles.horizontalMargin),
      child: _responsiveUtils.isPortraitMobile(context)
        ? Column(
            children: [
              CalendarDateIconWidget(
                calendarEvent: calendarEvent,
                width: double.infinity,
              ),
              Container(
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(CalendarEventInformationWidgetStyles.borderRadius),
                      bottomRight: Radius.circular(CalendarEventInformationWidgetStyles.borderRadius)
                    )
                  ),
                  color: Colors.white
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(CalendarEventInformationWidgetStyles.calendarInformationMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: CalendarEventInformationWidgetStyles.invitationMessageTextSize,
                          fontWeight: FontWeight.w500,
                          color: CalendarEventInformationWidgetStyles.invitationMessageColor
                        ),
                        children: [
                          TextSpan(
                            text: calendarEvent.organizerName,
                            style: const TextStyle(
                              color: CalendarEventInformationWidgetStyles.invitationMessageColor,
                              fontSize: CalendarEventInformationWidgetStyles.invitationMessageTextSize,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          TextSpan(text: AppLocalizations.of(context).invitationMessageCalendarInformation)
                        ]
                      )
                    ),
                    const SizedBox(height: CalendarEventInformationWidgetStyles.space),
                    if (calendarEvent.title?.isNotEmpty == true)
                      EventTitleWidget(title: calendarEvent.title!),
                    _buildEventTimeInformationWidget(),
                    if (calendarEvent.location?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: CalendarEventInformationWidgetStyles.fieldTopPadding),
                        child: EventLocationInformationWidget(
                          locationEvent: calendarEvent.location!,
                          onOpenComposerAction: onOpenComposerAction,
                          onOpenNewTabAction: onOpenNewTabAction,
                        ),
                      ),
                    if (calendarEvent.participants?.isNotEmpty == true && calendarEvent.organizer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: CalendarEventInformationWidgetStyles.fieldTopPadding),
                        child: EventAttendeeInformationWidget(
                          attendees: calendarEvent.participants!,
                          organizer: calendarEvent.organizer!,
                        ),
                      ),
                    if (eventActions.isNotEmpty)
                      CalendarEventActionButtonWidget(
                        eventActions: eventActions,
                        margin: EdgeInsetsDirectional.zero,
                        onMailToAttendeesAction: () => onMailtoAttendeesAction?.call(
                          calendarEvent.organizer,
                          calendarEvent.participants,
                        ),
                      ),
                  ],
                ),
              )
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarDateIconWidget(calendarEvent: calendarEvent),
              Expanded(child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(CalendarEventInformationWidgetStyles.borderRadius),
                      bottomRight: Radius.circular(CalendarEventInformationWidgetStyles.borderRadius)
                    )
                  ),
                  color: Colors.white
                ),
                padding: const EdgeInsets.all(CalendarEventInformationWidgetStyles.calendarInformationMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: CalendarEventInformationWidgetStyles.invitationMessageTextSize,
                          fontWeight: FontWeight.w500,
                          color: CalendarEventInformationWidgetStyles.invitationMessageColor
                        ),
                        children: [
                          TextSpan(
                            text: calendarEvent.organizerName,
                            style: const TextStyle(
                              color: CalendarEventInformationWidgetStyles.invitationMessageColor,
                              fontSize: CalendarEventInformationWidgetStyles.invitationMessageTextSize,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          TextSpan(text: AppLocalizations.of(context).invitationMessageCalendarInformation)
                        ]
                      )
                    ),
                    const SizedBox(height: CalendarEventInformationWidgetStyles.space),
                    if (calendarEvent.title?.isNotEmpty == true)
                      EventTitleWidget(title: calendarEvent.title!),
                    _buildEventTimeInformationWidget(),
                    if (calendarEvent.location?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: CalendarEventInformationWidgetStyles.fieldTopPadding),
                        child: EventLocationInformationWidget(
                          locationEvent: calendarEvent.location!,
                          onOpenComposerAction: onOpenComposerAction,
                          onOpenNewTabAction: onOpenNewTabAction,
                        ),
                      ),
                    if (calendarEvent.participants?.isNotEmpty == true && calendarEvent.organizer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: CalendarEventInformationWidgetStyles.fieldTopPadding),
                        child: EventAttendeeInformationWidget(
                          attendees: calendarEvent.participants!,
                          organizer: calendarEvent.organizer!,
                        ),
                      ),
                    if (eventActions.isNotEmpty)
                      CalendarEventActionButtonWidget(
                        eventActions: eventActions,
                        margin: EdgeInsetsDirectional.zero,
                        onMailToAttendeesAction: () => onMailtoAttendeesAction?.call(
                          calendarEvent.organizer,
                          calendarEvent.participants,
                        ),
                      ),
                  ],
                ),
              ))
            ],
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
        child: EventTimeInformationWidget(timeEvent: dateTimeEvent),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}