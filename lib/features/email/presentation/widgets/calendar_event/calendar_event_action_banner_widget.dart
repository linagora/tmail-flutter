
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_action_banner_styles.dart';

class CalendarEventActionBannerWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final List<String> listEmailAddressSender;

  const CalendarEventActionBannerWidget({
    super.key,
    required this.calendarEvent,
    required this.listEmailAddressSender,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(CalendarEventActionBannerStyles.borderRadius)),
        color: calendarEvent.getColorEventActionBanner(listEmailAddressSender).withOpacity(0.12)
      ),
      padding: const EdgeInsets.all(CalendarEventActionBannerStyles.contentPadding),
      margin: const EdgeInsets.symmetric(
        horizontal: CalendarEventActionBannerStyles.viewHorizontalMargin,
        vertical: CalendarEventActionBannerStyles.viewVerticalMargin,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calendarEvent.getIconEventAction(imagePaths).isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: SvgPicture.asset(
                calendarEvent.getIconEventAction(imagePaths),
                width: CalendarEventActionBannerStyles.iconSize,
                height: CalendarEventActionBannerStyles.iconSize,
                fit: BoxFit.fill,
              ),
            ),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: CalendarEventActionBannerStyles.titleTextSize,
                    fontWeight: FontWeight.w400,
                    color: calendarEvent.getColorEventActionText(listEmailAddressSender)
                  ),
                  children: [
                    TextSpan(
                      text: calendarEvent.getUserNameEventAction(
                        context: context,
                        imagePaths: imagePaths,
                        listEmailAddressSender: listEmailAddressSender
                      ),
                      style: TextStyle(
                        color: calendarEvent.getColorEventActionText(listEmailAddressSender),
                        fontSize: CalendarEventActionBannerStyles.titleTextSize,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    TextSpan(text: calendarEvent.getTitleEventAction(context, listEmailAddressSender))
                  ]
                )
              ),
              if (calendarEvent.getSubTitleEventAction(context).isNotEmpty)
                Text(
                  calendarEvent.getSubTitleEventAction(context),
                  style: const TextStyle(
                    color: AppColor.colorSubTitleEventActionText,
                    fontSize: CalendarEventActionBannerStyles.subTileTextSize,
                    fontWeight: FontWeight.w400
                  ),
                )
            ]
          ))
        ]
      ),
    );
  }
}