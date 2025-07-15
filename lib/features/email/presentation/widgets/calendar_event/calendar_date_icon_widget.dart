
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_date_icon_widget_styles.dart';

class CalendarDateIconWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final double width;

  const CalendarDateIconWidget({
    super.key,
    required this.calendarEvent,
    this.width = 100
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: width,
      margin: const EdgeInsets.all(CalendarIconWidgetStyles.margin),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(CalendarIconWidgetStyles.borderRadius))),
        color: Colors.white,
        shadows: [
          BoxShadow(
            color: AppColor.colorShadowBgContentEmail,
            blurRadius: 80,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColor.colorShadowCalendarDateIcon,
            blurRadius: 3,
            offset: Offset(0, 1),
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppColor.primaryColor,
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: CalendarIconWidgetStyles.headerVerticalContentPadding,
              horizontal: CalendarIconWidgetStyles.headerHorizontalContentPadding
            ),
            width: width,
            child: Text(
              calendarEvent.monthStartDateAsString,
              textAlign: TextAlign.center,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: CalendarIconWidgetStyles.headerTextSize,
                fontWeight: FontWeight.w400,
                color: Colors.white
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(CalendarIconWidgetStyles.bodyContentPadding),
            child: Text(
              calendarEvent.dayStartDateAsString,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: CalendarIconWidgetStyles.bodyDayTextSize,
                fontWeight: FontWeight.w700,
                color: Colors.black
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: CalendarIconWidgetStyles.bodyContentPadding),
            child: Divider(color: AppColor.colorCalendarEventInformationStroke, height: 2)
          ),
          Padding(
            padding: const EdgeInsets.all(CalendarIconWidgetStyles.bodyContentPadding),
            child: Text(
              calendarEvent.weekDayStartDateAsString,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: CalendarIconWidgetStyles.bodyWeekDayTextSize,
                fontWeight: FontWeight.w400,
                color: Colors.black
              ),
            ),
          ),
        ],
      ),
    );
  }
}