
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_action_banner_styles.dart';

class CalendarEventActionBannerWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final Set<EmailAddress>? listFromEmailAddress;

  const CalendarEventActionBannerWidget({
    super.key,
    required this.calendarEvent,
    required this.listFromEmailAddress,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(CalendarEventActionBannerStyles.borderRadius)),
        color: calendarEvent.getColorEventActionBanner(_getSenderEmailAddress()).withOpacity(0.12)
      ),
      padding: const EdgeInsets.all(CalendarEventActionBannerStyles.contentPadding),
      margin: const EdgeInsets.symmetric(
        vertical: CalendarEventActionBannerStyles.viewVerticalMargin,
        horizontal: CalendarEventActionBannerStyles.viewHorizontalMargin,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calendarEvent.getIconEventAction(imagePaths).isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: SvgPicture.asset(
                calendarEvent.getIconEventAction(imagePaths),
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
            ),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: calendarEvent.getColorEventActionText(_getSenderEmailAddress())
                  ),
                  children: [
                    TextSpan(
                      text: calendarEvent.getUserNameEventAction(
                        context: context,
                        imagePaths: imagePaths,
                        senderEmailAddress: _getSenderEmailAddress()
                      ),
                      style: TextStyle(
                        color: calendarEvent.getColorEventActionText(_getSenderEmailAddress()),
                        fontSize: 20,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    TextSpan(text: calendarEvent.getTitleEventAction(context, _getSenderEmailAddress()))
                  ]
                )
              ),
              if (calendarEvent.getSubTitleEventAction(context).isNotEmpty)
                Text(
                  calendarEvent.getSubTitleEventAction(context),
                  style: const TextStyle(
                    color: AppColor.colorSubTitleEventActionText,
                    fontSize: 16,
                    fontWeight: FontWeight.w400
                  ),
                )
            ]
          ))
        ]
      ),
    );
  }

  String _getSenderEmailAddress() {
    if (listFromEmailAddress?.isNotEmpty == true) {
      final senderEmailAddress = listFromEmailAddress!.first.emailAddress;
      log('CalendarEventActionBannerWidget::getSenderEmailAddress: $senderEmailAddress');
      return senderEmailAddress;
    } else {
      return '';
    }
  }
}