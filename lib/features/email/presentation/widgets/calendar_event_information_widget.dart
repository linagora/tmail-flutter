
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_information_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_date_icon_widget.dart';

class CalendarEventInformationWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;

  const CalendarEventInformationWidget({
    super.key,
    required this.calendarEvent
  });

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
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
      child: responsiveUtils.isPortraitMobile(context)
        ? Column(
            children: [
              Container(
                padding: const EdgeInsets.all(CalendarEventInformationWidgetStyles.calendarDateIconMargin),
                color: CalendarEventInformationWidgetStyles.calendarDateIconBackgroundColor,
                child: CalendarDateIconWidget(
                  calendarEvent: calendarEvent,
                  width: double.infinity,
                ),
              )
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(CalendarEventInformationWidgetStyles.calendarDateIconMargin),
                color: CalendarEventInformationWidgetStyles.calendarDateIconBackgroundColor,
                child: CalendarDateIconWidget(calendarEvent: calendarEvent),
              ),
              Expanded(child: Container(color: Colors.white))
            ],
          ),
    );
  }
}